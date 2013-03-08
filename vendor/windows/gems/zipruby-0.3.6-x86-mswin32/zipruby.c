/* rdoc source */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef _WIN32
#if RUBY_VERSION_MAJOR == 1 && RUBY_VERSION_MINOR == 8
#include <windows.h>
#endif
#include <io.h>
#include <fcntl.h>
#include <share.h>
#endif

#include "tmpfile.h"
#include "ruby.h"

#ifndef _WIN32
#ifndef HAVE_MKSTEMP
int _zip_mkstemp(char *);
#define mkstemp _zip_mkstemp
#endif
#endif

static int write_from_proc(VALUE proc, int fd);
static VALUE proc_call(VALUE proc);

char *zipruby_tmpnam(void *data, int len) {
  char *filnam;

#ifdef _WIN32
  int fd;
  char tmpdirnam[_MAX_PATH];
  char tmpfilnam[_MAX_PATH];
  int namlen;

  memset(tmpdirnam, 0, _MAX_PATH);

  if (GetTempPathA(_MAX_PATH, tmpdirnam) == 0) {
    return NULL;
  }

  memset(tmpfilnam, 0, _MAX_PATH);

  if (GetTempFileNameA(tmpdirnam, "zrb", 0, tmpfilnam) == 0) {
    return NULL;
  }

  namlen = strlen(tmpfilnam) + 1;

  if ((filnam = calloc(namlen, sizeof(char))) == NULL) {
    return NULL;
  }

  if (strcpy_s(filnam, namlen, tmpfilnam) != 0) {
    free(filnam);
    return NULL;
  }

  if (data) {
    if ((_sopen_s(&fd, filnam, _O_WRONLY | _O_BINARY, _SH_DENYRD, _S_IWRITE)) != 0) {
      free(filnam);
      return NULL;
    }

    if (len < 0) {
      if (write_from_proc((VALUE) data, fd) == -1) {
        free(filnam);
        return NULL;
      }
    } else {
      if (_write(fd, data, len) == -1) {
        free(filnam);
        return NULL;
      }
    }

    if (_close(fd) == -1) {
      free(filnam);
      return NULL;
    }
  }
#else
  int fd;
#ifdef P_tmpdir
  int namlen = 16 + strlen(P_tmpdir);
  char *dirnam = P_tmpdir;
#else
  int namlen = 20;
  char *dirnam = "/tmp";
#endif

  if ((filnam = calloc(namlen, sizeof(char))) == NULL) {
    return NULL;
  }

  strcpy(filnam, dirnam);
  strcat(filnam, "/zipruby.XXXXXX");

  if ((fd = mkstemp(filnam)) == -1) {
    free(filnam);
    return NULL;
  }

  if (data) {
    if (len < 0) {
      if (write_from_proc((VALUE) data, fd) == -1) {
        free(filnam);
        return NULL;
      }
    } else {
      if (write(fd, data, len) == -1) {
        free(filnam);
        return NULL;
      }
    }
  }

  if (close(fd) == -1) {
    free(filnam);
    return NULL;
  }
#endif

  return filnam;
}

void zipruby_rmtmp(const char *tmpfilnam) {
  struct stat st;

  if (!tmpfilnam) {
    return;
  }

  if (stat(tmpfilnam, &st) != 0) {
    return;
  }

#ifdef _WIN32
  _unlink(tmpfilnam);
#else
  unlink(tmpfilnam);
#endif
}

static int write_from_proc(VALUE proc, int fd) {
  while (1) {
    VALUE src = rb_protect(proc_call, proc, NULL);

    if (TYPE(src) != T_STRING) {
      break;
    }

    if (RSTRING_LEN(src) < 1) {
      break;
    }

#ifdef _WIN32
    if (_write(fd, RSTRING_PTR(src), RSTRING_LEN(src)) == -1) {
      return -1;
    }
#else
    if (write(fd, RSTRING_PTR(src), RSTRING_LEN(src)) == -1) {
      return -1;
    }
#endif
  }

  return 0;
}

static VALUE proc_call(VALUE proc) {
  return rb_funcall(proc, rb_intern("call"), 0);
}
#ifdef _WIN32
__declspec(dllexport) void Init_zipruby(void);
#endif

#include "zipruby.h"
#include "zipruby_zip.h"
#include "zipruby_archive.h"
#include "zipruby_file.h"
#include "zipruby_stat.h"
#include "zipruby_error.h"

void Init_zipruby() {
  Init_zipruby_zip();
  Init_zipruby_archive();
  Init_zipruby_file();
  Init_zipruby_stat();
  Init_zipruby_error();
}
#include <errno.h>
#include <zlib.h>

#include "zip.h"
#include "zipint.h"
#include "zipruby.h"
#include "zipruby_archive.h"
#include "zipruby_zip_source_proc.h"
#include "zipruby_zip_source_io.h"
#include "tmpfile.h"
#include "ruby.h"
#ifndef RUBY_VM
#include "rubyio.h"
#endif

static VALUE zipruby_archive_alloc(VALUE klass);
static void zipruby_archive_mark(struct zipruby_archive *p);
static void zipruby_archive_free(struct zipruby_archive *p);
static VALUE zipruby_archive_s_open(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_s_open_buffer(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_s_decrypt(VALUE self, VALUE path, VALUE password);
static VALUE zipruby_archive_s_encrypt(VALUE self, VALUE path, VALUE password);
static VALUE zipruby_archive_close(VALUE self);
static VALUE zipruby_archive_num_files(VALUE self);
static VALUE zipruby_archive_get_name(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_fopen(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_get_stat(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_buffer(VALUE self, VALUE name, VALUE source);
static VALUE zipruby_archive_add_file(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_io(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_function(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_replace_buffer(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_replace_file(int argc, VALUE* argv, VALUE self);
static VALUE zipruby_archive_replace_io(int argc, VALUE* argv, VALUE self);
static VALUE zipruby_archive_replace_function(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_or_replace_buffer(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_or_replace_file(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_or_replace_io(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_add_or_replace_function(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_update(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_get_comment(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_set_comment(VALUE self, VALUE comment);
static VALUE zipruby_archive_locate_name(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_get_fcomment(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_archive_set_fcomment(VALUE self, VALUE index, VALUE comment);
static VALUE zipruby_archive_fdelete(VALUE self, VALUE index);
static VALUE zipruby_archive_frename(VALUE self, VALUE index, VALUE name);
static VALUE zipruby_archive_funchange(VALUE self, VALUE index);
static VALUE zipruby_archive_funchange_all(VALUE self);
static VALUE zipruby_archive_unchange(VALUE self);
static VALUE zipruby_archive_revert(VALUE self);
static VALUE zipruby_archive_each(VALUE self);
static VALUE zipruby_archive_commit(VALUE self);
static VALUE zipruby_archive_is_open(VALUE self);
static VALUE zipruby_archive_decrypt(VALUE self, VALUE password);
static VALUE zipruby_archive_encrypt(VALUE self, VALUE password);
static VALUE zipruby_archive_read(VALUE self);
static VALUE zipruby_archive_add_dir(VALUE self, VALUE name);

extern VALUE Zip;
VALUE Archive;
extern VALUE File;
extern VALUE Stat;
extern VALUE Error;

void Init_zipruby_archive() {
  Archive = rb_define_class_under(Zip, "Archive", rb_cObject);
  rb_define_alloc_func(Archive, zipruby_archive_alloc);
  rb_include_module(Archive, rb_mEnumerable);
  rb_define_singleton_method(Archive, "open", zipruby_archive_s_open, -1);
  rb_define_singleton_method(Archive, "open_buffer", zipruby_archive_s_open_buffer, -1);
  rb_define_singleton_method(Archive, "decrypt", zipruby_archive_s_decrypt, 2);
  rb_define_singleton_method(Archive, "encrypt", zipruby_archive_s_encrypt, 2);
  rb_define_method(Archive, "close", zipruby_archive_close, 0);
  rb_define_method(Archive, "num_files", zipruby_archive_num_files, 0);
  rb_define_method(Archive, "get_name", zipruby_archive_get_name, -1);
  rb_define_method(Archive, "fopen", zipruby_archive_fopen, -1);
  rb_define_method(Archive, "get_stat", zipruby_archive_get_stat, -1);
  rb_define_method(Archive, "add_buffer", zipruby_archive_add_buffer, 2);
  rb_define_method(Archive, "add_file", zipruby_archive_add_file, -1);
  rb_define_method(Archive, "add_io", zipruby_archive_add_io, -1);
  rb_define_method(Archive, "add", zipruby_archive_add_function, -1);
  rb_define_method(Archive, "replace_buffer", zipruby_archive_replace_buffer, -1);
  rb_define_method(Archive, "replace_file", zipruby_archive_replace_file, -1);
  rb_define_method(Archive, "replace_io", zipruby_archive_replace_io, -1);
  rb_define_method(Archive, "replace", zipruby_archive_replace_function, -1);
  rb_define_method(Archive, "add_or_replace_buffer", zipruby_archive_add_or_replace_buffer, -1);
  rb_define_method(Archive, "add_or_replace_file", zipruby_archive_add_or_replace_file, -1);
  rb_define_method(Archive, "add_or_replace_io", zipruby_archive_add_or_replace_io, -1);
  rb_define_method(Archive, "add_or_replace", zipruby_archive_add_or_replace_function, -1);
  rb_define_method(Archive, "update", zipruby_archive_update, -1);
  rb_define_method(Archive, "<<", zipruby_archive_add_io, -1);
  rb_define_method(Archive, "get_comment", zipruby_archive_get_comment, -1);
  rb_define_method(Archive, "comment", zipruby_archive_get_comment, -1);
  rb_define_method(Archive, "comment=", zipruby_archive_set_comment, 1);
  rb_define_method(Archive, "locate_name", zipruby_archive_locate_name, -1);
  rb_define_method(Archive, "get_fcomment", zipruby_archive_get_fcomment, -1);
  rb_define_method(Archive, "set_fcomment", zipruby_archive_set_fcomment, 2);
  rb_define_method(Archive, "fdelete", zipruby_archive_fdelete, 1);
  rb_define_method(Archive, "frename", zipruby_archive_frename, 2);
  rb_define_method(Archive, "funchange", zipruby_archive_funchange, 1);
  rb_define_method(Archive, "funchange_all", zipruby_archive_funchange_all, 0);
  rb_define_method(Archive, "unchange", zipruby_archive_unchange, 0);
  rb_define_method(Archive, "frevert", zipruby_archive_unchange, 1);
  rb_define_method(Archive, "revert", zipruby_archive_revert, 0);
  rb_define_method(Archive, "each", zipruby_archive_each, 0);
  rb_define_method(Archive, "commit", zipruby_archive_commit, 0);
  rb_define_method(Archive, "open?", zipruby_archive_is_open, 0);
  rb_define_method(Archive, "decrypt", zipruby_archive_decrypt, 1);
  rb_define_method(Archive, "encrypt", zipruby_archive_encrypt, 1);
  rb_define_method(Archive, "read", zipruby_archive_read, 0);
  rb_define_method(Archive, "add_dir", zipruby_archive_add_dir, 1);
}

static VALUE zipruby_archive_alloc(VALUE klass) {
  struct zipruby_archive *p = ALLOC(struct zipruby_archive);

  p->archive = NULL;
  p->path = Qnil;
  p->flags = 0;
  p->tmpfilnam = NULL;
  p->buffer = Qnil;
  p->sources = Qnil;

  return Data_Wrap_Struct(klass, zipruby_archive_mark, zipruby_archive_free, p);
}

static void zipruby_archive_mark(struct zipruby_archive *p) {
  rb_gc_mark(p->path);
  rb_gc_mark(p->buffer);
  rb_gc_mark(p->sources);
}

static void zipruby_archive_free(struct zipruby_archive *p) {
  if (p->tmpfilnam) {
    zipruby_rmtmp(p->tmpfilnam);
    free(p->tmpfilnam);
  }

  xfree(p);
}

/* */
static VALUE zipruby_archive_s_open(int argc, VALUE *argv, VALUE self) {
  VALUE path, flags, comp_level;
  VALUE archive;
  struct zipruby_archive *p_archive;
  int i_flags = 0;
  int errorp;
  int i_comp_level = Z_BEST_COMPRESSION;

  rb_scan_args(argc, argv, "12", &path, &flags, &comp_level);
  Check_Type(path, T_STRING);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  if (!NIL_P(comp_level)) {
    i_comp_level = NUM2INT(comp_level);

    if (i_comp_level != Z_DEFAULT_COMPRESSION && i_comp_level != Z_NO_COMPRESSION && (i_comp_level < Z_BEST_SPEED || Z_BEST_COMPRESSION < i_comp_level)) {
      rb_raise(rb_eArgError, "Wrong compression level %d", i_comp_level);
    }
  }

  archive = rb_funcall(Archive, rb_intern("new"), 0);
  Data_Get_Struct(archive, struct zipruby_archive, p_archive);

  if ((p_archive->archive = zip_open(RSTRING_PTR(path), i_flags, &errorp)) == NULL) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Open archive failed - %s: %s", RSTRING_PTR(path), errstr);
  }

  p_archive->archive->comp_level = i_comp_level;
  p_archive->path = path;
  p_archive->flags = i_flags;
  p_archive->sources = rb_ary_new();

  if (rb_block_given_p()) {
    VALUE retval;
    int status;

    retval = rb_protect(rb_yield, archive, &status);
    zipruby_archive_close(archive);

    if (status != 0) {
      rb_jump_tag(status);
    }

    return retval;
  } else {
    return archive;
  }
}

/* */
static VALUE zipruby_archive_s_open_buffer(int argc, VALUE *argv, VALUE self) {
  VALUE buffer, flags, comp_level;
  VALUE archive;
  struct zipruby_archive *p_archive;
  void *data = NULL;
  int len = 0, i_flags = 0;
  int errorp;
  int i_comp_level = Z_BEST_COMPRESSION;
  int buffer_is_temporary = 0;

  rb_scan_args(argc, argv, "03", &buffer, &flags, &comp_level);

  if (FIXNUM_P(buffer) && NIL_P(comp_level)) {
    comp_level = flags;
    flags = buffer;
    buffer = Qnil;
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  if (!NIL_P(comp_level)) {
    i_comp_level = NUM2INT(comp_level);

    if (i_comp_level != Z_DEFAULT_COMPRESSION && i_comp_level != Z_NO_COMPRESSION && (i_comp_level < Z_BEST_SPEED || Z_BEST_COMPRESSION < i_comp_level)) {
      rb_raise(rb_eArgError, "Wrong compression level %d", i_comp_level);
    }
  }

  if (i_flags & ZIP_CREATE) {
    if (!NIL_P(buffer)) {
      Check_Type(buffer, T_STRING);
    } else {
      buffer = rb_str_new("", 0);
      buffer_is_temporary = 1;
    }

    i_flags = (i_flags | ZIP_TRUNC);
  } else if (TYPE(buffer) == T_STRING) {
    data = RSTRING_PTR(buffer);
    len = RSTRING_LEN(buffer);
  } else if (rb_obj_is_instance_of(buffer, rb_cProc)) {
    data = (void *) buffer;
    len = -1;
  } else {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected String or Proc)", rb_class2name(CLASS_OF(buffer)));
  }

  archive = rb_funcall(Archive, rb_intern("new"), 0);
  Data_Get_Struct(archive, struct zipruby_archive, p_archive);

  if ((p_archive->tmpfilnam = zipruby_tmpnam(data, len)) == NULL) {
    rb_raise(Error, "Open archive failed: Failed to create temporary file");
  }

  if ((p_archive->archive = zip_open(p_archive->tmpfilnam, i_flags, &errorp)) == NULL) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Open archive failed: %s", errstr);
  }

  p_archive->archive->comp_level = i_comp_level;
  p_archive->path = rb_str_new2(p_archive->tmpfilnam);
  p_archive->flags = i_flags;
  p_archive->buffer = buffer;
  p_archive->sources = rb_ary_new();

  if (rb_block_given_p()) {
    VALUE retval;
    int status;

    retval = rb_protect(rb_yield, archive, &status);
    zipruby_archive_close(archive);

    if (status != 0) {
      rb_jump_tag(status);
    }

    return buffer_is_temporary ? buffer : retval;
  } else {
    return archive;
  }
}

/* */
static VALUE zipruby_archive_s_decrypt(VALUE self, VALUE path, VALUE password) {
  int res;
  int errorp, wrongpwd;
  long pwdlen;

  Check_Type(path, T_STRING);
  Check_Type(password, T_STRING);
  pwdlen = RSTRING_LEN(password);

  if (pwdlen < 1) {
    rb_raise(Error, "Decrypt archive failed - %s: Password is empty", RSTRING_PTR(path));
  } else if (pwdlen > 0xff) {
    rb_raise(Error, "Decrypt archive failed - %s: Password is too long", RSTRING_PTR(path));
  }

  res = zip_decrypt(RSTRING_PTR(path), RSTRING_PTR(password), pwdlen, &errorp, &wrongpwd);

  if (res == -1) {
    if (wrongpwd) {
      rb_raise(Error, "Decrypt archive failed - %s: Wrong password", RSTRING_PTR(path));
    } else {
      char errstr[ERRSTR_BUFSIZE];
      zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
      rb_raise(Error, "Decrypt archive failed - %s: %s", RSTRING_PTR(path), errstr);
    }
  }

  return (res > 0) ? Qtrue : Qfalse;
}

/* */
static VALUE zipruby_archive_s_encrypt(VALUE self, VALUE path, VALUE password) {
  int res;
  int errorp;
  long pwdlen;

  Check_Type(path, T_STRING);
  Check_Type(password, T_STRING);
  pwdlen = RSTRING_LEN(password);

  if (pwdlen < 1) {
    rb_raise(Error, "Encrypt archive failed - %s: Password is empty", RSTRING_PTR(path));
  } else if (pwdlen > 0xff) {
    rb_raise(Error, "Encrypt archive failed - %s: Password is too long", RSTRING_PTR(path));
  }

  res = zip_encrypt(RSTRING_PTR(path), RSTRING_PTR(password), pwdlen, &errorp);

  if (res == -1) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Encrypt archive failed - %s: %s", RSTRING_PTR(path), errstr);
  }

  return (res > 0) ? Qtrue : Qfalse;
}

/* */
static VALUE zipruby_archive_close(VALUE self) {
  struct zipruby_archive *p_archive;
  int changed, survivors;

  if (!zipruby_archive_is_open(self)) {
    return Qfalse;
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  changed = _zip_changed(p_archive->archive, &survivors);

  if (zip_close(p_archive->archive) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Close archive failed: %s", zip_strerror(p_archive->archive));
  }

  if (!NIL_P(p_archive->sources)){
    rb_ary_clear(p_archive->sources);
  }

  if (!NIL_P(p_archive->buffer) && changed) {
    rb_funcall(p_archive->buffer, rb_intern("replace"), 1, rb_funcall(self, rb_intern("read"), 0));
  }

  zipruby_rmtmp(p_archive->tmpfilnam);
  p_archive->archive = NULL;
  p_archive->flags = 0;

  return Qtrue;
}

/* */
static VALUE zipruby_archive_num_files(VALUE self) {
  struct zipruby_archive *p_archive;
  int num_files;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);
  num_files = zip_get_num_files(p_archive->archive);

  return INT2NUM(num_files);
}

/* */
static VALUE zipruby_archive_get_name(int argc, VALUE *argv, VALUE self) {
  VALUE index, flags;
  struct zipruby_archive *p_archive;
  int i_flags = 0;
  const char *name;

  rb_scan_args(argc, argv, "11", &index, &flags);
  Check_Type(index, T_FIXNUM);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if ((name = zip_get_name(p_archive->archive, NUM2INT(index), i_flags)) == NULL) {
    rb_raise(Error, "Get name failed at %d: %s", index, zip_strerror(p_archive->archive));
  }

  return (name != NULL) ? rb_str_new2(name) : Qnil;
}

/* */
static VALUE zipruby_archive_fopen(int argc, VALUE *argv, VALUE self) {
  VALUE index, flags, stat_flags, file;

  rb_scan_args(argc, argv, "12", &index, &flags, &stat_flags);
  file = rb_funcall(File, rb_intern("new"), 4, self, index, flags, stat_flags);

  if (rb_block_given_p()) {
    VALUE retval;
    int status;

    retval = rb_protect(rb_yield, file, &status);
    rb_funcall(file, rb_intern("close"), 0);

    if (status != 0) {
      rb_jump_tag(status);
    }

    return retval;
  } else {
    return file;
  }
}

/* */
static VALUE zipruby_archive_get_stat(int argc, VALUE *argv, VALUE self) {
  VALUE index, flags;

  rb_scan_args(argc, argv, "11", &index, &flags);

  return rb_funcall(Stat, rb_intern("new"), 3, self, index, flags);
}

/* */
static VALUE zipruby_archive_add_buffer(VALUE self, VALUE name, VALUE source) {
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  char *data;
  size_t len;

  Check_Type(name, T_STRING);
  Check_Type(source, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  len = RSTRING_LEN(source);

  if ((data = malloc(len)) == NULL) {
    rb_raise(rb_eRuntimeError, "Add file failed: Cannot allocate memory");
  }

  memset(data, 0, len);
  memcpy(data, RSTRING_PTR(source), len);

  if ((zsource = zip_source_buffer(p_archive->archive, data, len, 1)) == NULL) {
    free(data);
    rb_raise(Error, "Add file failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  if (zip_add(p_archive->archive, RSTRING_PTR(name), zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Add file failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_replace_buffer(int argc, VALUE *argv, VALUE self) {
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  VALUE index, source, flags;
  int i_index, i_flags = 0;
  char *data;
  size_t len;

  rb_scan_args(argc, argv, "21", &index, &source, &flags);

  if (TYPE(index) != T_STRING && !FIXNUM_P(index)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Fixnum or String)", rb_class2name(CLASS_OF(index)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(source, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (FIXNUM_P(index)) {
    i_index = NUM2INT(index);
  } else if ((i_index = zip_name_locate(p_archive->archive, RSTRING_PTR(index), i_flags)) == -1) {
    rb_raise(Error, "Replace file failed - %s: Archive does not contain a file", RSTRING_PTR(index));
  }

  len = RSTRING_LEN(source);

  if ((data = malloc(len)) == NULL) {
    rb_raise(rb_eRuntimeError, "Replace file failed: Cannot allocate memory");
  }

  memcpy(data, RSTRING_PTR(source), len);

  if ((zsource = zip_source_buffer(p_archive->archive, data, len, 1)) == NULL) {
    free(data);
    rb_raise(Error, "Replace file failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  if (zip_replace(p_archive->archive, i_index, zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Replace file failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_add_or_replace_buffer(int argc, VALUE *argv, VALUE self) {
  struct zipruby_archive *p_archive;
  VALUE name, source, flags;
  int index, i_flags = 0;

  rb_scan_args(argc, argv, "21", &name, &source, &flags);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  index = zip_name_locate(p_archive->archive, RSTRING_PTR(name), i_flags);

  if (index >= 0) {
    VALUE _args[] = { INT2NUM(index), source };
    return zipruby_archive_replace_buffer(2, _args, self);
  } else {
    return zipruby_archive_add_buffer(self, name, source);
  }
}

/* */
static VALUE zipruby_archive_add_file(int argc, VALUE *argv, VALUE self) {
  VALUE name, fname;
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;

  rb_scan_args(argc, argv, "11", &name, &fname);

  if (NIL_P(fname)) {
    fname = name;
    name = Qnil;
  }

  Check_Type(fname, T_STRING);

  if (NIL_P(name)) {
    name = rb_funcall(rb_cFile, rb_intern("basename"), 1, fname);
  }

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if ((zsource = zip_source_file(p_archive->archive, RSTRING_PTR(fname), 0, -1)) == NULL) {
    rb_raise(Error, "Add file failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  if (zip_add(p_archive->archive, RSTRING_PTR(name), zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Add file failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_replace_file(int argc, VALUE* argv, VALUE self) {
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  VALUE index, fname, flags;
  int i_index, i_flags = 0;

  rb_scan_args(argc, argv, "21", &index, &fname, &flags);

  if (TYPE(index) != T_STRING && !FIXNUM_P(index)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Fixnum or String)", rb_class2name(CLASS_OF(index)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(fname, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (FIXNUM_P(index)) {
    i_index = NUM2INT(index);
  } else if ((i_index = zip_name_locate(p_archive->archive, RSTRING_PTR(index), i_flags)) == -1) {
    rb_raise(Error, "Replace file failed - %s: Archive does not contain a file", RSTRING_PTR(index));
  }

  if ((zsource = zip_source_file(p_archive->archive, RSTRING_PTR(fname), 0, -1)) == NULL) {
    rb_raise(Error, "Replace file failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  if (zip_replace(p_archive->archive, i_index, zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Replace file failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_add_or_replace_file(int argc, VALUE *argv, VALUE self) {
  VALUE name, fname, flags;
  struct zipruby_archive *p_archive;
  int index, i_flags = 0;

  rb_scan_args(argc, argv, "12", &name, &fname, &flags);

  if (NIL_P(flags) && FIXNUM_P(fname)) {
    flags = fname;
    fname = Qnil;
  }

  if (NIL_P(fname)) {
    fname = name;
    name = Qnil;
  }

  Check_Type(fname, T_STRING);

  if (NIL_P(name)) {
    name = rb_funcall(rb_cFile, rb_intern("basename"), 1, fname);
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  index = zip_name_locate(p_archive->archive, RSTRING_PTR(name), i_flags);

  if (index >= 0) {
    VALUE _args[] = { INT2NUM(index), fname };
    return zipruby_archive_replace_file(2, _args, self);
  } else {
    VALUE _args[] = { name, fname };
    return zipruby_archive_add_file(2, _args, self);
  }
}

/* */
static VALUE zipruby_archive_add_io(int argc, VALUE *argv, VALUE self) {
  VALUE name, file, mtime;
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  struct read_io *z;

  rb_scan_args(argc, argv, "11", &name, &file);

  if (NIL_P(file)) {
    file = name;
    name = Qnil;
  }

  Check_IO(file);

  if (NIL_P(name)) {
    if (rb_obj_is_kind_of(file, rb_cFile)) {
      name = rb_funcall(rb_cFile, rb_intern("basename"), 1, rb_funcall(file, rb_intern("path"), 0));
    } else {
      rb_raise(rb_eRuntimeError, "Add io failed - %s: Entry name is not given", RSTRING(rb_inspect(file)));
    }
  }

  if (rb_obj_is_kind_of(file, rb_cFile)) {
    mtime = rb_funcall(file, rb_intern("mtime"), 0);
  } else {
    mtime = rb_funcall(rb_cTime, rb_intern("now"), 0);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive); 
  Check_Archive(p_archive);

  if ((z = malloc(sizeof(struct read_io))) == NULL) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(rb_eRuntimeError, "Add io failed - %s: Cannot allocate memory", RSTRING(rb_inspect(file)));
  }

  z->io = file;
  rb_ary_push(p_archive->sources, file);
  z->mtime = TIME2LONG(mtime);

  if ((zsource = zip_source_io(p_archive->archive, z)) == NULL) {
    free(z);
    rb_raise(Error, "Add io failed - %s: %s", RSTRING(rb_inspect(file)), zip_strerror(p_archive->archive));
  }

  if (zip_add(p_archive->archive, RSTRING_PTR(name), zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Add io failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_replace_io(int argc, VALUE *argv, VALUE self) {
  VALUE file, index, flags, mtime;
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  struct read_io *z;
  int i_index, i_flags = 0;

  rb_scan_args(argc, argv, "21", &index, &file, &flags);

  if (TYPE(index) != T_STRING && !FIXNUM_P(index)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Fixnum or String)", rb_class2name(CLASS_OF(index)));
  }

  Check_IO(file);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  if (rb_obj_is_kind_of(file, rb_cFile)) {
    mtime = rb_funcall(file, rb_intern("mtime"), 0);
  } else {
    mtime = rb_funcall(rb_cTime, rb_intern("now"), 0);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (FIXNUM_P(index)) {
    i_index = NUM2INT(index);
  } else if ((i_index = zip_name_locate(p_archive->archive, RSTRING_PTR(index), i_flags)) == -1) {
    rb_raise(Error, "Replace io failed - %s: Archive does not contain a file", RSTRING_PTR(index));
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive); 
  Check_Archive(p_archive);

  if ((z = malloc(sizeof(struct read_io))) == NULL) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(rb_eRuntimeError, "Replace io failed at %d - %s: Cannot allocate memory", i_index, RSTRING(rb_inspect(file)));
  }

  z->io = file;
  rb_ary_push(p_archive->sources, file);
  z->mtime = TIME2LONG(mtime);

  if ((zsource = zip_source_io(p_archive->archive, z)) == NULL) {
    free(z);
    rb_raise(Error, "Replace io failed at %d - %s: %s", i_index, RSTRING(rb_inspect(file)), zip_strerror(p_archive->archive));
  }

  if (zip_replace(p_archive->archive, i_index, zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Replace io failed at %d - %s: %s", i_index, RSTRING(rb_inspect(file)), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_add_or_replace_io(int argc, VALUE *argv, VALUE self) {
  VALUE name, io, flags;
  struct zipruby_archive *p_archive;
  int index, i_flags = 0;

  rb_scan_args(argc, argv, "21", &name, &io, &flags);
  Check_IO(io);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  index = zip_name_locate(p_archive->archive, RSTRING_PTR(name), i_flags);

  if (index >= 0) {
    VALUE _args[] = {INT2NUM(index), io, flags};
    return zipruby_archive_replace_io(2, _args, self);
  } else {
    VALUE _args[2] = { name, io };
    return zipruby_archive_add_io(2, _args, self);
  }
}

/* */
static VALUE zipruby_archive_add_function(int argc, VALUE *argv, VALUE self) {
  VALUE name, mtime;
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  struct read_proc *z;

  rb_scan_args(argc, argv, "11", &name, &mtime);
  rb_need_block();
  Check_Type(name, T_STRING);

  if (NIL_P(mtime)) {
    mtime = rb_funcall(rb_cTime, rb_intern("now"), 0);
  } else if (!rb_obj_is_instance_of(mtime, rb_cTime)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Time)", rb_class2name(CLASS_OF(mtime)));
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive); 
  Check_Archive(p_archive);

  if ((z = malloc(sizeof(struct read_proc))) == NULL) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(rb_eRuntimeError, "Add failed - %s: Cannot allocate memory", RSTRING_PTR(name));
  }

  z->proc = rb_block_proc();
  rb_ary_push(p_archive->sources, z->proc);
  z->mtime = TIME2LONG(mtime);

  if ((zsource = zip_source_proc(p_archive->archive, z)) == NULL) {
    free(z);
    rb_raise(Error, "Add failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  if (zip_add(p_archive->archive, RSTRING_PTR(name), zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Add file failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_replace_function(int argc, VALUE *argv, VALUE self) {
  VALUE index, flags, mtime;
  struct zipruby_archive *p_archive;
  struct zip_source *zsource;
  struct read_proc *z;
  int i_index, i_flags = 0;

  rb_scan_args(argc, argv, "12", &index, &mtime, &flags);
  rb_need_block();

  if (TYPE(index) != T_STRING && !FIXNUM_P(index)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Fixnum or String)", rb_class2name(CLASS_OF(index)));
  }

  if (NIL_P(mtime)) {
    mtime = rb_funcall(rb_cTime, rb_intern("now"), 0);
  } else if (!rb_obj_is_instance_of(mtime, rb_cTime)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Time)", rb_class2name(CLASS_OF(mtime)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive); 
  Check_Archive(p_archive);

  if (FIXNUM_P(index)) {
    i_index = NUM2INT(index);
  } else if ((i_index = zip_name_locate(p_archive->archive, RSTRING_PTR(index), i_flags)) == -1) {
    rb_raise(Error, "Replace file failed - %s: Archive does not contain a file", RSTRING_PTR(index));
  }

  if ((z = malloc(sizeof(struct read_proc))) == NULL) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(rb_eRuntimeError, "Replace failed at %d: Cannot allocate memory", i_index);
  }

  z->proc = rb_block_proc();
  rb_ary_push(p_archive->sources, z->proc);
  z->mtime = TIME2LONG(mtime);

  if ((zsource = zip_source_proc(p_archive->archive, z)) == NULL) {
    free(z);
    rb_raise(Error, "Replace failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  if (zip_replace(p_archive->archive, i_index, zsource) == -1) {
    zip_source_free(zsource);
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Replace failed at %d: %s", i_index, zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_add_or_replace_function(int argc, VALUE *argv, VALUE self) {
  VALUE name, mtime, flags;
  struct zipruby_archive *p_archive;
  int index, i_flags = 0;

  rb_scan_args(argc, argv, "12", &name, &mtime, &flags);

  if (NIL_P(flags) && FIXNUM_P(mtime)) {
    flags = mtime;
    mtime = Qnil;
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  index = zip_name_locate(p_archive->archive, RSTRING_PTR(name), i_flags);

  if (index >= 0) {
    VALUE _args[] = { INT2NUM(index), mtime };
    return zipruby_archive_replace_function(2, _args, self);
  } else {
    VALUE _args[] = { name, mtime };
    return zipruby_archive_add_function(2, _args, self);
  }
}

/* */
static VALUE zipruby_archive_update(int argc, VALUE *argv, VALUE self) {
  struct zipruby_archive *p_archive, *p_srcarchive;
  VALUE srcarchive, flags;
  int i, num_files, i_flags = 0;

  rb_scan_args(argc, argv, "11", &srcarchive, &flags);

  if (!rb_obj_is_instance_of(srcarchive, Archive)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Zip::Archive)", rb_class2name(CLASS_OF(srcarchive)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);
  Data_Get_Struct(srcarchive, struct zipruby_archive, p_srcarchive);
  Check_Archive(p_srcarchive);

  num_files = zip_get_num_files(p_srcarchive->archive);

  for (i = 0; i < num_files; i++) {
    struct zip_source *zsource;
    struct zip_file *fzip;
    struct zip_stat sb;
    char *buf;
    const char *name;
    int index, error;

    zip_stat_init(&sb);

    if (zip_stat_index(p_srcarchive->archive, i, 0, &sb)) {
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(Error, "Update archive failed: %s", zip_strerror(p_srcarchive->archive));
    }

    if ((buf = malloc(sb.size)) == NULL) {
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(rb_eRuntimeError, "Update archive failed: Cannot allocate memory");
    }

    fzip = zip_fopen_index(p_srcarchive->archive, i, 0);

    if (fzip == NULL) {
      free(buf);
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(Error, "Update archive failed: %s", zip_strerror(p_srcarchive->archive));
    }

    if (zip_fread(fzip, buf, sb.size) == -1) {
      free(buf);
      zip_fclose(fzip);
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(Error, "Update archive failed: %s", zip_file_strerror(fzip));
    }

    if ((error = zip_fclose(fzip)) != 0) {
      char errstr[ERRSTR_BUFSIZE];
      free(buf);
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      zip_error_to_str(errstr, ERRSTR_BUFSIZE, error, errno);
      rb_raise(Error, "Update archive failed: %s", errstr);
    }

    if ((zsource = zip_source_buffer(p_archive->archive, buf, sb.size, 1)) == NULL) {
      free(buf);
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(Error, "Update archive failed: %s", zip_strerror(p_archive->archive));
    }

    if ((name = zip_get_name(p_srcarchive->archive, i, 0)) == NULL) {
      zip_source_free(zsource);
      zip_unchange_all(p_archive->archive);
      zip_unchange_archive(p_archive->archive);
      rb_raise(Error, "Update archive failed: %s", zip_strerror(p_srcarchive->archive));
    }

    index = zip_name_locate(p_archive->archive, name, i_flags);

    if (index >= 0) {
      if (zip_replace(p_archive->archive, i, zsource) == -1) {
        zip_source_free(zsource);
        zip_unchange_all(p_archive->archive);
        zip_unchange_archive(p_archive->archive);
        rb_raise(Error, "Update archive failed: %s", zip_strerror(p_archive->archive));
      }
    } else {
      if (zip_add(p_archive->archive, name, zsource) == -1) {
        zip_source_free(zsource);
        zip_unchange_all(p_archive->archive);
        zip_unchange_archive(p_archive->archive);
        rb_raise(Error, "Update archive failed: %s", zip_strerror(p_archive->archive));
      }
    }
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_get_comment(int argc, VALUE *argv, VALUE self) {
  VALUE flags;
  struct zipruby_archive *p_archive;
  const char *comment;
  int lenp, i_flags = 0;

  rb_scan_args(argc, argv, "01", &flags);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  // XXX: How is the error checked?
  comment = zip_get_archive_comment(p_archive->archive, &lenp, i_flags);

  return comment ? rb_str_new(comment, lenp) : Qnil;
}

/* */
static VALUE zipruby_archive_set_comment(VALUE self, VALUE comment) {
  struct zipruby_archive *p_archive;
  const char *s_comment = NULL;
  int len = 0;

  if (!NIL_P(comment)) {
    Check_Type(comment, T_STRING);
    s_comment = RSTRING_PTR(comment);
    len = RSTRING_LEN(comment);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_set_archive_comment(p_archive->archive, s_comment, len) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Comment archived failed: %s", zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_locate_name(int argc, VALUE *argv, VALUE self) {
  VALUE fname, flags;
  struct zipruby_archive *p_archive;
  int i_flags = 0;

  rb_scan_args(argc, argv, "11", &fname, &flags);
  Check_Type(fname, T_STRING);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  return INT2NUM(zip_name_locate(p_archive->archive, RSTRING_PTR(fname), i_flags));
}

/* */
static VALUE zipruby_archive_get_fcomment(int argc, VALUE *argv, VALUE self) {
  VALUE index, flags;
  struct zipruby_archive *p_archive;
  const char *comment;
  int lenp, i_flags = 0;

  rb_scan_args(argc, argv, "11", &index, &flags);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  // XXX: How is the error checked?
  comment = zip_get_file_comment(p_archive->archive, NUM2INT(index), &lenp, i_flags);

  return comment ? rb_str_new(comment, lenp) : Qnil;
}

/* */
static VALUE zipruby_archive_set_fcomment(VALUE self, VALUE index, VALUE comment) {
  struct zipruby_archive *p_archive;
  char *s_comment = NULL;
  int len = 0;

  if (!NIL_P(comment)) {
    Check_Type(comment, T_STRING);
    s_comment = RSTRING_PTR(comment);
    len = RSTRING_LEN(comment);
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_set_file_comment(p_archive->archive, NUM2INT(index), s_comment, len) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Comment file failed at %d: %s", NUM2INT(index), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_fdelete(VALUE self, VALUE index) {
  struct zipruby_archive *p_archive;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_delete(p_archive->archive, NUM2INT(index)) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Delete file failed at %d: %s", NUM2INT(index), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_frename(VALUE self, VALUE index, VALUE name) {
  struct zipruby_archive *p_archive;

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_rename(p_archive->archive, NUM2INT(index), RSTRING_PTR(name)) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Rename file failed at %d: %s", NUM2INT(index), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_funchange(VALUE self, VALUE index) {
  struct zipruby_archive *p_archive;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_unchange(p_archive->archive, NUM2INT(index)) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Unchange file failed at %d: %s", NUM2INT(index), zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_funchange_all(VALUE self) {
  struct zipruby_archive *p_archive;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_unchange_all(p_archive->archive) == -1) {
    rb_raise(Error, "Unchange all file failed: %s", zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_unchange(VALUE self) {
  struct zipruby_archive *p_archive;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_unchange_archive(p_archive->archive) == -1) {
    rb_raise(Error, "Unchange archive failed: %s", zip_strerror(p_archive->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_revert(VALUE self) {
  zipruby_archive_funchange_all(self);
  zipruby_archive_unchange(self);

  return Qnil;
}

/* */
static VALUE zipruby_archive_each(VALUE self) {
  struct zipruby_archive *p_archive;
  int i, num_files;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);
  num_files = zip_get_num_files(p_archive->archive);

  for (i = 0; i < num_files; i++) {
    VALUE file;
    int status;

    file = rb_funcall(File, rb_intern("new"), 2, self, INT2NUM(i));
    rb_protect(rb_yield, file, &status);
    rb_funcall(file, rb_intern("close"), 0);

    if (status != 0) {
      rb_jump_tag(status);
    }
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_commit(VALUE self) {
  struct zipruby_archive *p_archive;
  int changed, survivors;
  int errorp;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  changed = _zip_changed(p_archive->archive, &survivors);

  if (zip_close(p_archive->archive) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Commit archive failed: %s", zip_strerror(p_archive->archive));
  }

  if (!NIL_P(p_archive->sources)){
    rb_ary_clear(p_archive->sources);
  }

  if (!NIL_P(p_archive->buffer) && changed) {
    rb_funcall(p_archive->buffer, rb_intern("replace"), 1, rb_funcall(self, rb_intern("read"), 0));
  }

  p_archive->archive = NULL;
  p_archive->flags = (p_archive->flags & ~(ZIP_CREATE | ZIP_EXCL));

  if ((p_archive->archive = zip_open(RSTRING_PTR(p_archive->path), p_archive->flags, &errorp)) == NULL) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Commit archive failed: %s", errstr);
  }

  return Qnil;
}

/* */
static VALUE zipruby_archive_is_open(VALUE self) {
  struct zipruby_archive *p_archive;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  return (p_archive->archive != NULL) ? Qtrue : Qfalse;
}

/* */
static VALUE zipruby_archive_decrypt(VALUE self, VALUE password) {
  VALUE retval;
  struct zipruby_archive *p_archive;
  long pwdlen;
  int changed, survivors;
  int errorp;

  Check_Type(password, T_STRING);
  pwdlen = RSTRING_LEN(password);

  if (pwdlen < 1) {
    rb_raise(Error, "Decrypt archive failed: Password is empty");
  } else if (pwdlen > 0xff) {
    rb_raise(Error, "Decrypt archive failed: Password is too long");
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  changed = _zip_changed(p_archive->archive, &survivors);

  if (zip_close(p_archive->archive) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Decrypt archive failed: %s", zip_strerror(p_archive->archive));
  }

  if (!NIL_P(p_archive->buffer) && changed) {
    rb_funcall(p_archive->buffer, rb_intern("replace"), 1, rb_funcall(self, rb_intern("read"), 0));
  }

  p_archive->archive = NULL;
  p_archive->flags = (p_archive->flags & ~(ZIP_CREATE | ZIP_EXCL));

  retval = zipruby_archive_s_decrypt(Archive, p_archive->path, password);

  if ((p_archive->archive = zip_open(RSTRING_PTR(p_archive->path), p_archive->flags, &errorp)) == NULL) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Decrypt archive failed: %s", errstr);
  }

  return retval;
}

/* */
static VALUE zipruby_archive_encrypt(VALUE self, VALUE password) {
  VALUE retval;
  struct zipruby_archive *p_archive;
  long pwdlen;
  int changed, survivors;
  int errorp;

  Check_Type(password, T_STRING);
  pwdlen = RSTRING_LEN(password);

  if (pwdlen < 1) {
    rb_raise(Error, "Encrypt archive failed: Password is empty");
  } else if (pwdlen > 0xff) {
    rb_raise(Error, "Encrypt archive failed: Password is too long");
  }

  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  changed = _zip_changed(p_archive->archive, &survivors);

  if (zip_close(p_archive->archive) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Encrypt archive failed: %s", zip_strerror(p_archive->archive));
  }

  if (!NIL_P(p_archive->buffer) && changed) {
    rb_funcall(p_archive->buffer, rb_intern("replace"), 1, rb_funcall(self, rb_intern("read"), 0));
  }

  p_archive->archive = NULL;
  p_archive->flags = (p_archive->flags & ~(ZIP_CREATE | ZIP_EXCL));

  retval = zipruby_archive_s_encrypt(Archive, p_archive->path, password);

  if ((p_archive->archive = zip_open(RSTRING_PTR(p_archive->path), p_archive->flags, &errorp)) == NULL) {
    char errstr[ERRSTR_BUFSIZE];
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, errorp, errno);
    rb_raise(Error, "Encrypt archive failed: %s", errstr);
  }

  return retval;
}

/* */
static VALUE zipruby_archive_read(VALUE self) {
  VALUE retval = Qnil;
  struct zipruby_archive *p_archive;
  FILE *fzip;
  char buf[DATA_BUFSIZE];
  ssize_t n;
  int block_given;

  Data_Get_Struct(self, struct zipruby_archive, p_archive);

  if (NIL_P(p_archive->path)) {
    rb_raise(rb_eRuntimeError, "invalid Zip::Archive");
  }

#ifdef _WIN32
  if (fopen_s(&fzip, RSTRING_PTR(p_archive->path), "rb") != 0) {
    rb_raise(Error, "Read archive failed: Cannot open archive");
  }
#else
  if ((fzip = fopen(RSTRING_PTR(p_archive->path), "rb")) == NULL) {
    rb_raise(Error, "Read archive failed: Cannot open archive");
  }
#endif

  block_given = rb_block_given_p();

  while ((n = fread(buf, 1, sizeof(buf), fzip)) > 0) {
    if (block_given) {
      rb_yield(rb_str_new(buf, n));
    } else {
      if (NIL_P(retval)) {
        retval = rb_str_new(buf, n);
      } else {
        rb_str_buf_cat(retval, buf, n);
      }
    }
  }

#if defined(RUBY_VM) && defined(_WIN32)
  _fclose_nolock(fzip);
#elif defined(RUBY_WIN32_H)
#undef fclose
  fclose(fzip);
#define fclose(f) rb_w32_fclose(f)
#else
  fclose(fzip);
#endif

  if (n == -1) {
    rb_raise(Error, "Read archive failed");
  }

  return retval;
}

/* */
static VALUE zipruby_archive_add_dir(VALUE self, VALUE name) {
  struct zipruby_archive *p_archive;

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (zip_add_dir(p_archive->archive, RSTRING_PTR(name)) == -1) {
    zip_unchange_all(p_archive->archive);
    zip_unchange_archive(p_archive->archive);
    rb_raise(Error, "Add dir failed - %s: %s", RSTRING_PTR(name), zip_strerror(p_archive->archive));
  }

  return Qnil;
}
#include "zipruby.h"
#include "zipruby_error.h"
#include "ruby.h"

extern VALUE Zip;
VALUE Error;

void Init_zipruby_error() {
  Error = rb_define_class_under(Zip, "Error", rb_eStandardError);
}
#include <errno.h>

#include "zip.h"
#include "zipint.h"
#include "zipruby.h"
#include "zipruby_archive.h"
#include "zipruby_file.h"
#include "zipruby_stat.h"
#include "ruby.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))

static VALUE zipruby_file(VALUE klass);
static VALUE zipruby_file_alloc(VALUE klass);
static void zipruby_file_mark(struct zipruby_file *p);
static void zipruby_file_free(struct zipruby_file *p);
static VALUE zipruby_file_initialize(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_file_close(VALUE self);
static VALUE zipruby_file_read(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_file_stat(VALUE self);
static VALUE zipruby_file_get_comment(int argc, VALUE *argv, VALUE self);
static VALUE zipruby_file_set_comment(VALUE self, VALUE comment);
static VALUE zipruby_file_delete(VALUE self);
static VALUE zipruby_file_rename(VALUE self, VALUE name);
static VALUE zipruby_file_unchange(VALUE self);
static VALUE zipruby_file_name(VALUE self);
static VALUE zipruby_file_index(VALUE self);
static VALUE zipruby_file_crc(VALUE self);
static VALUE zipruby_file_size(VALUE self);
static VALUE zipruby_file_mtime(VALUE self);
static VALUE zipruby_file_comp_size(VALUE self);
static VALUE zipruby_file_comp_method(VALUE self);
static VALUE zipruby_file_encryption_method(VALUE self);
static VALUE zipruby_file_is_directory(VALUE self);

extern VALUE Zip;
extern VALUE Archive;
VALUE File;
extern VALUE Stat;
extern VALUE Error;

void Init_zipruby_file() {
  File = rb_define_class_under(Zip, "File", rb_cObject);
  rb_define_alloc_func(File, zipruby_file_alloc);
  rb_define_method(File, "initialize", zipruby_file_initialize, -1);
  rb_define_method(File, "close", zipruby_file_close, 0);
  rb_define_method(File, "read", zipruby_file_read, -1);
  rb_define_method(File, "stat", zipruby_file_stat, 0);
  rb_define_method(File, "get_comment", zipruby_file_get_comment, -1);
  rb_define_method(File, "comment", zipruby_file_get_comment, -1);
  rb_define_method(File, "comment=", zipruby_file_set_comment, 1);
  rb_define_method(File, "delete", zipruby_file_delete, 0);
  rb_define_method(File, "rename", zipruby_file_rename, 1);
  rb_define_method(File, "unchange", zipruby_file_unchange, 1);
  rb_define_method(File, "revert", zipruby_file_unchange, 1);
  rb_define_method(File, "name", zipruby_file_name, 0);
  rb_define_method(File, "index", zipruby_file_index, 0);
  rb_define_method(File, "crc", zipruby_file_crc, 0);
  rb_define_method(File, "size", zipruby_file_size, 0);
  rb_define_method(File, "mtime", zipruby_file_mtime, 0);
  rb_define_method(File, "comp_size", zipruby_file_comp_size, 0);
  rb_define_method(File, "comp_method", zipruby_file_comp_method, 0);
  rb_define_method(File, "encryption_method", zipruby_file_encryption_method, 0);
  rb_define_method(File, "directory?", zipruby_file_is_directory, 0);
}

static VALUE zipruby_file_alloc(VALUE klass) {
  struct zipruby_file *p = ALLOC(struct zipruby_file);

  p->archive = NULL;
  p->file = NULL;
  p->sb = NULL;

  return Data_Wrap_Struct(klass, zipruby_file_mark, zipruby_file_free, p);
}

static void zipruby_file_mark(struct zipruby_file *p) {
  if (p->archive) { rb_gc_mark(p->v_archive); }
  if (p->sb) { rb_gc_mark(p->v_sb); }
}

static void zipruby_file_free(struct zipruby_file *p) {
  xfree(p);
}

/* */
static VALUE zipruby_file_initialize(int argc, VALUE *argv, VALUE self) {
  VALUE archive, index, flags, stat_flags;
  struct zipruby_archive *p_archive;
  struct zipruby_file *p_file;
  struct zipruby_stat *p_stat;
  struct zip_file *fzip;
  char *fname = NULL;
  int i_index = -1, i_flags = 0;

  rb_scan_args(argc, argv, "22", &archive,  &index, &flags, &stat_flags);

  if (!rb_obj_is_instance_of(archive, Archive)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Zip::Archive)", rb_class2name(CLASS_OF(archive)));
  }

  switch (TYPE(index)) {
  case T_STRING: fname = RSTRING_PTR(index); break;
  case T_FIXNUM: i_index = NUM2INT(index); break;
  default:
    rb_raise(rb_eTypeError, "wrong argument type %s (expected String or Fixnum)", rb_class2name(CLASS_OF(index)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(archive, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);

  if (fname) {
    fzip = zip_fopen(p_archive->archive, fname, i_flags);

    if (fzip == NULL) {
      rb_raise(Error, "Open file failed - %s: %s", fname, zip_strerror(p_archive->archive));
    }
  } else {
    fzip = zip_fopen_index(p_archive->archive, i_index, i_flags);

    if (fzip == NULL) {
      rb_raise(Error, "Open file failed at %d: %s", i_index, zip_strerror(p_archive->archive));
    }
  }

  Data_Get_Struct(self, struct zipruby_file, p_file);
  p_file->v_archive = archive;
  p_file->archive = p_archive->archive;
  p_file->file = fzip;
  p_file->v_sb = rb_funcall(Stat, rb_intern("new"), 3, archive, index, stat_flags);
  Data_Get_Struct(p_file->v_sb, struct zipruby_stat, p_stat);
  p_file->sb = p_stat->sb;

  return Qnil;
}

/* */
static VALUE zipruby_file_close(VALUE self) {
  struct zipruby_file *p_file;
  int error;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  if ((error = zip_fclose(p_file->file)) != 0) {
    char errstr[ERRSTR_BUFSIZE];
    zip_unchange(p_file->archive, p_file->sb->index);
    zip_error_to_str(errstr, ERRSTR_BUFSIZE, error, errno);
    rb_raise(Error, "Close file failed: %s", errstr);
  }

  p_file->archive = NULL;
  p_file->file = NULL;
  p_file->sb = NULL;

  return Qnil;
}

/* */
static VALUE zipruby_file_read(int argc, VALUE *argv, VALUE self) {
  VALUE size, retval = Qnil;
  struct zipruby_file *p_file;
  struct zip_stat sb;
  int block_given;
  size_t bytes_left;
  char buf[DATA_BUFSIZE];
  ssize_t n;

  rb_scan_args(argc, argv, "01", &size);
  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);
  zip_stat_init(&sb);

  if (p_file->archive->cdir->entry[0].bitflags & ZIP_GPBF_ENCRYPTED) {
    rb_raise(Error, "Read file failed: File encrypted");
  }

  if (zip_stat_index(p_file->archive, p_file->sb->index, 0, &sb)) {
    rb_raise(Error, "Read file failed: %s", zip_strerror(p_file->archive));
  }

  if (NIL_P(size)) {
    bytes_left = sb.size;
  } else {
    bytes_left = NUM2LONG(size);
  }

  if (bytes_left <= 0) {
    return Qnil;
  }

  block_given = rb_block_given_p();

  while ((n = zip_fread(p_file->file, buf, MIN(bytes_left, sizeof(buf)))) > 0) {
    if (block_given) {
      rb_yield(rb_str_new(buf, n));
    } else {
      if (NIL_P(retval)) {
        retval = rb_str_new(buf, n);
      } else {
        rb_str_buf_cat(retval, buf, n);
      }
    }

    bytes_left -= n;
  }

  if (n == -1) {
    rb_raise(Error, "Read file failed: %s", zip_file_strerror(p_file->file));
  }

  return retval;
}

/* */
static VALUE zipruby_file_stat(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return p_file->v_sb;
}

/* */
static VALUE zipruby_file_get_comment(int argc, VALUE *argv, VALUE self) {
  VALUE flags;
  struct zipruby_file *p_file;
  const char *comment;
  int lenp, i_flags = 0;

  rb_scan_args(argc, argv, "01", &flags);

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  // XXX: How is the error checked?
  comment = zip_get_file_comment(p_file->archive, p_file->sb->index, &lenp, i_flags);

  return comment ? rb_str_new(comment, lenp) : Qnil;
}

/* */
static VALUE zipruby_file_set_comment(VALUE self, VALUE comment) {
  struct zipruby_file *p_file;
  char *s_comment = NULL;
  int len = 0;

  if (!NIL_P(comment)) {
    Check_Type(comment, T_STRING);
    s_comment = RSTRING_PTR(comment);
    len = RSTRING_LEN(comment);
  }

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  if (zip_set_file_comment(p_file->archive, p_file->sb->index, s_comment, len) == -1) {
    zip_unchange_all(p_file->archive);
    zip_unchange_archive(p_file->archive);
    rb_raise(Error, "Comment file failed - %s: %s", p_file->sb->name, zip_strerror(p_file->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_file_delete(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  if (zip_delete(p_file->archive, p_file->sb->index) == -1) {
    zip_unchange_all(p_file->archive);
    zip_unchange_archive(p_file->archive);
    rb_raise(Error, "Delete file failed - %s: %s", p_file->sb->name, zip_strerror(p_file->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_file_rename(VALUE self, VALUE name) {
  struct zipruby_file *p_file;

  Check_Type(name, T_STRING);
  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  if (zip_rename(p_file->archive, p_file->sb->index, RSTRING_PTR(name)) == -1) {
    zip_unchange_all(p_file->archive);
    zip_unchange_archive(p_file->archive);
    rb_raise(Error, "Rename file failed - %s: %s", p_file->sb->name, zip_strerror(p_file->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_file_unchange(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  if (zip_unchange(p_file->archive, p_file->sb->index) == -1) {
    rb_raise(Error, "Unchange file failed - %s: %s", p_file->sb->name, zip_strerror(p_file->archive));
  }

  return Qnil;
}

/* */
static VALUE zipruby_file_name(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_name(p_file->v_sb);
}

/* */
static VALUE zipruby_file_index(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_index(p_file->v_sb);
}

/* */
static VALUE zipruby_file_crc(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_crc(p_file->v_sb);
}

/* */
static VALUE zipruby_file_size(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_size(p_file->v_sb);
}

/* */
static VALUE zipruby_file_mtime(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_mtime(p_file->v_sb);
}

/* */
static VALUE zipruby_file_comp_size(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_comp_size(p_file->v_sb);
}

/* */
static VALUE zipruby_file_comp_method(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_comp_method(p_file->v_sb);
}

/* */
static VALUE zipruby_file_encryption_method(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_encryption_method(p_file->v_sb);
}

/* */
static VALUE zipruby_file_is_directory(VALUE self) {
  struct zipruby_file *p_file;

  Data_Get_Struct(self, struct zipruby_file, p_file);
  Check_File(p_file);

  return zipruby_stat_is_directory(p_file->v_sb);
}
#include <string.h>

#include "zip.h"
#include "zipruby.h"
#include "zipruby_archive.h"
#include "zipruby_stat.h"
#include "ruby.h"

static VALUE zipruby_stat_alloc(VALUE klass);
static void zipruby_stat_free(struct zipruby_stat *p);
static VALUE zipruby_stat_initialize(int argc, VALUE *argv, VALUE self);

extern VALUE Zip;
extern VALUE Archive;
VALUE Stat;
extern VALUE Error;

void Init_zipruby_stat() {
  Stat = rb_define_class_under(Zip, "Stat", rb_cObject);
  rb_define_alloc_func(Stat, zipruby_stat_alloc);
  rb_define_method(Stat, "initialize", zipruby_stat_initialize, -1);
  rb_define_method(Stat, "name", zipruby_stat_name, 0);
  rb_define_method(Stat, "index", zipruby_stat_index, 0);
  rb_define_method(Stat, "crc", zipruby_stat_crc, 0);
  rb_define_method(Stat, "size", zipruby_stat_size, 0);
  rb_define_method(Stat, "mtime", zipruby_stat_mtime, 0);
  rb_define_method(Stat, "comp_size", zipruby_stat_comp_size, 0);
  rb_define_method(Stat, "comp_method", zipruby_stat_comp_method, 0);
  rb_define_method(Stat, "encryption_method", zipruby_stat_encryption_method, 0);
  rb_define_method(Stat, "directory?", zipruby_stat_is_directory, 0);
}

static VALUE zipruby_stat_alloc(VALUE klass) {
  struct zipruby_stat *p = ALLOC(struct zipruby_stat);

  p->sb = ALLOC(struct zip_stat);
  zip_stat_init(p->sb);

  return Data_Wrap_Struct(klass, 0, zipruby_stat_free, p);
}

static void zipruby_stat_free(struct zipruby_stat *p) {
  xfree(p->sb);
  xfree(p);
}

/* */
static VALUE zipruby_stat_initialize(int argc, VALUE *argv, VALUE self) {
  VALUE archive, index, flags;
  struct zipruby_archive *p_archive;
  struct zipruby_stat *p_stat;
  char *fname = NULL;
  int i_index = -1, i_flags = 0;

  rb_scan_args(argc, argv, "21", &archive, &index, &flags);

  if (!rb_obj_is_instance_of(archive, Archive)) {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected Zip::Archive)", rb_class2name(CLASS_OF(archive)));
  }

  switch (TYPE(index)) {
  case T_STRING: fname = RSTRING_PTR(index); break;
  case T_FIXNUM: i_index = NUM2INT(index); break;
  default:
    rb_raise(rb_eTypeError, "wrong argument type %s (expected String or Fixnum)", rb_class2name(CLASS_OF(index)));
  }

  if (!NIL_P(flags)) {
    i_flags = NUM2INT(flags);
  }

  Data_Get_Struct(archive, struct zipruby_archive, p_archive);
  Check_Archive(p_archive);
  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  if (fname) {
    if (zip_stat(p_archive->archive, fname, i_flags, p_stat->sb) != 0) {
      rb_raise(Error, "Obtain file status failed - %s: %s", fname, zip_strerror(p_archive->archive));
    }
  } else {
    if (zip_stat_index(p_archive->archive, i_index, i_flags, p_stat->sb) != 0) {
      rb_raise(Error, "Obtain file status failed at %d: %s", i_index, zip_strerror(p_archive->archive));
    }
  }

  return Qnil;
}

/* */
VALUE zipruby_stat_name(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return p_stat->sb->name ? rb_str_new2(p_stat->sb->name) : Qnil;
}

/* */
VALUE zipruby_stat_index(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return INT2NUM(p_stat->sb->index);
}

/* */
VALUE zipruby_stat_crc(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return UINT2NUM(p_stat->sb->crc);
}

/* */
VALUE zipruby_stat_size(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return LONG2NUM(p_stat->sb->size);
}

/* */
VALUE zipruby_stat_mtime(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return rb_funcall(rb_cTime, rb_intern("at"), 1,  LONG2NUM((long) p_stat->sb->mtime));
}

/* */
VALUE zipruby_stat_comp_size(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return LONG2NUM(p_stat->sb->comp_size);
}

/* */
VALUE zipruby_stat_comp_method(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return INT2NUM(p_stat->sb->comp_method);
}

/* */
VALUE zipruby_stat_encryption_method(VALUE self) {
  struct zipruby_stat *p_stat;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);

  return INT2NUM(p_stat->sb->encryption_method);
}

/* */
VALUE zipruby_stat_is_directory(VALUE self) {
  struct zipruby_stat *p_stat;
  const char *name;
  size_t name_len;
  off_t size;

  Data_Get_Struct(self, struct zipruby_stat, p_stat);
  name = p_stat->sb->name;
  size = p_stat->sb->size;

  if (!name || size != 0) {
    return Qfalse;
  }

  name_len = strlen(name);

  if (name_len > 0 && name[name_len - 1] == '/') {
    return Qtrue;
  } else {
    return Qfalse;
  }
}
#include <zlib.h>

#include "ruby.h"
#include "zip.h"
#include "zipruby.h"
#include "zipruby_zip.h"

VALUE Zip;

void Init_zipruby_zip() {
  Zip = rb_define_module("Zip");
  rb_define_const(Zip, "VERSION", rb_str_new2(VERSION));

  rb_define_const(Zip, "CREATE",    INT2NUM(ZIP_CREATE));
  rb_define_const(Zip, "EXCL",      INT2NUM(ZIP_EXCL));
  rb_define_const(Zip, "CHECKCONS", INT2NUM(ZIP_CHECKCONS));
  rb_define_const(Zip, "TRUNC",     INT2NUM(ZIP_TRUNC));

  rb_define_const(Zip, "FL_NOCASE",     INT2NUM(ZIP_FL_NOCASE));
  rb_define_const(Zip, "FL_NODIR",      INT2NUM(ZIP_FL_NODIR));
  rb_define_const(Zip, "FL_COMPRESSED", INT2NUM(ZIP_FL_COMPRESSED));
  rb_define_const(Zip, "FL_UNCHANGED",  INT2NUM(ZIP_FL_UNCHANGED));

  rb_define_const(Zip, "CM_DEFAULT"   ,     INT2NUM(ZIP_CM_DEFAULT));
  rb_define_const(Zip, "CM_STORE",          INT2NUM(ZIP_CM_STORE));
  rb_define_const(Zip, "CM_SHRINK",         INT2NUM(ZIP_CM_SHRINK));
  rb_define_const(Zip, "CM_REDUCE_1",       INT2NUM(ZIP_CM_REDUCE_1));
  rb_define_const(Zip, "CM_REDUCE_2",       INT2NUM(ZIP_CM_REDUCE_2));
  rb_define_const(Zip, "CM_REDUCE_3",       INT2NUM(ZIP_CM_REDUCE_3));
  rb_define_const(Zip, "CM_REDUCE_4",       INT2NUM(ZIP_CM_REDUCE_4));
  rb_define_const(Zip, "CM_IMPLODE",        INT2NUM(ZIP_CM_IMPLODE));
  rb_define_const(Zip, "CM_DEFLATE",        INT2NUM(ZIP_CM_DEFLATE));
  rb_define_const(Zip, "CM_DEFLATE64",      INT2NUM(ZIP_CM_DEFLATE64));
  rb_define_const(Zip, "CM_PKWARE_IMPLODE", INT2NUM(ZIP_CM_PKWARE_IMPLODE));
  rb_define_const(Zip, "CM_BZIP2",          INT2NUM(ZIP_CM_BZIP2));

  rb_define_const(Zip, "EM_NONE",        INT2NUM(ZIP_EM_NONE));
  rb_define_const(Zip, "EM_TRAD_PKWARE", INT2NUM(ZIP_EM_TRAD_PKWARE));
  // XXX: Strong Encryption Header not parsed yet

  rb_define_const(Zip, "NO_COMPRESSION",      INT2NUM(Z_NO_COMPRESSION));
  rb_define_const(Zip, "BEST_SPEED",          INT2NUM(Z_BEST_SPEED));
  rb_define_const(Zip, "BEST_COMPRESSION",    INT2NUM(Z_BEST_COMPRESSION));
  rb_define_const(Zip, "DEFAULT_COMPRESSION", INT2NUM(Z_DEFAULT_COMPRESSION));
}
#include <string.h>

#include "zip.h"
#include "zipint.h"
#include "zipruby_zip_source_io.h"
#include "ruby.h"

#define IO_READ_BUFSIZE 8192

static VALUE io_read(VALUE io) {
  return rb_funcall(io, rb_intern("read"), 1, INT2FIX(IO_READ_BUFSIZE));
}

static ssize_t read_io(void *state, void *data, size_t len, enum zip_source_cmd cmd) {
  struct read_io *z;
  VALUE src;
  char *buf;
  size_t n;
  int status = 0;

  z = (struct read_io *) state;
  buf = (char *) data;

  switch (cmd) {
  case ZIP_SOURCE_OPEN:
    return 0;

  case ZIP_SOURCE_READ:
    src = rb_protect(io_read, z->io, NULL);

    if (status != 0) {
      VALUE message, clazz;

#if defined(RUBY_VM)
      message = rb_funcall(rb_errinfo(), rb_intern("message"), 0);
      clazz = CLASS_OF(rb_errinfo());
#else
      message = rb_funcall(ruby_errinfo, rb_intern("message"), 0);
      clazz = CLASS_OF(ruby_errinfo);
#endif

      rb_warn("Error in IO: %s (%s)", RSTRING_PTR(message), rb_class2name(clazz));
      return -1;
    }

    if (TYPE(src) != T_STRING) {
      return 0;
    }

    n = RSTRING_LEN(src);

    if (n > 0) {
      n = (n > len) ? len : n;
      memcpy(buf, RSTRING_PTR(src), n);
    }

    return n;

  case ZIP_SOURCE_CLOSE:
    return 0;

  case ZIP_SOURCE_STAT:
    {
      struct zip_stat *st = (struct zip_stat *)data;
      zip_stat_init(st);
      st->mtime = z->mtime;
      return sizeof(*st);
    }

  case ZIP_SOURCE_ERROR:
    return 0;

  case ZIP_SOURCE_FREE:
    free(z);
    return 0;
  }

  return -1;
}

struct zip_source *zip_source_io(struct zip *za, struct read_io *z) {
  struct zip_source *zs;
  zs = zip_source_function(za, read_io, z);
  return zs;
}
#include <string.h>

#include "zip.h"
#include "zipint.h"
#include "zipruby_zip_source_proc.h"
#include "ruby.h"

static VALUE proc_call(VALUE proc) {
  return rb_funcall(proc, rb_intern("call"), 0);
}

static ssize_t read_proc(void *state, void *data, size_t len, enum zip_source_cmd cmd) {
  struct read_proc *z;
  VALUE src;
  char *buf;
  size_t n;
  int status = 0;

  z = (struct read_proc *) state;
  buf = (char *) data;

  switch (cmd) {
  case ZIP_SOURCE_OPEN:
    return 0;

  case ZIP_SOURCE_READ:
    src = rb_protect(proc_call, z->proc, &status);

    if (status != 0) {
      VALUE message, clazz;

#if defined(RUBY_VM)
      message = rb_funcall(rb_errinfo(), rb_intern("message"), 0);
      clazz = CLASS_OF(rb_errinfo());
#else
      message = rb_funcall(ruby_errinfo, rb_intern("message"), 0);
      clazz = CLASS_OF(ruby_errinfo);
#endif

      rb_warn("Error in Proc: %s (%s)", RSTRING_PTR(message), rb_class2name(clazz));
      return -1;
    }


    if (TYPE(src) != T_STRING) {
      src = rb_funcall(src, rb_intern("to_s"), 0);
    }

    n = RSTRING_LEN(src);

    if (n > 0) {
      n = (n > len) ? len : n;
      memcpy(buf, RSTRING_PTR(src), n);
    }

    return n;

  case ZIP_SOURCE_CLOSE:
    return 0;

  case ZIP_SOURCE_STAT:
    {
      struct zip_stat *st = (struct zip_stat *)data;
      zip_stat_init(st);
      st->mtime = z->mtime;
      return sizeof(*st);
    }

  case ZIP_SOURCE_ERROR:
    return 0;

  case ZIP_SOURCE_FREE:
    free(z);
    return 0;
  }

  return -1;
}

struct zip_source *zip_source_proc(struct zip *za, struct read_proc *z) {
  struct zip_source *zs;
  zs = zip_source_function(za, read_proc, z);
  return zs;
}
