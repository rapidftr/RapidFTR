= Zip/Ruby

Copyright (c) 2008-2010 SUGAWARA Genki <sgwr_dts@yahoo.co.jp>

== Description

Ruby bindings for libzip.

libzip is a C library for reading, creating, and modifying zip archives.

== Project Page

http://rubyforge.org/projects/zipruby

== Install

gem install zipruby

== Download

https://rubyforge.org/frs/?group_id=6124

== Example
=== reading zip archive

    require 'zipruby'
    
    Zip::Archive.open('filename.zip') do |ar|
      n = ar.num_files # number of entries
    
      n.times do |i|
        entry_name = ar.get_name(i) # get entry name from archive
    
        # open entry
        ar.fopen(entry_name) do |f| # or ar.fopen(i) do |f|
          name = f.name           # name of the file
          size = f.size           # size of file (uncompressed)
          comp_size = f.comp_size # size of file (compressed)
    
          content = f.read # read entry content
        end
      end
    
      # Zip::Archive includes Enumerable
      entry_names = ar.map do |f|
        f.name
      end
    end
    
    # read huge entry
    BUFSIZE = 8192
    
    Zip::Archive.open('filename.zip') do |ar|
      ar.each do |f|
        buf = ''
    
        while chunk = f.read(BUFSIZE)
          buf << chunk
        end
        # or
        # f.read do |chunk|
        #   buf << chunk
        # end
      end
    end

=== creating zip archive

    require 'zipruby'
    
    bar_txt =  open('bar.txt')
    
    Zip::Archive.open('filename.zip', Zip::CREATE) do |ar|
      # if overwrite: ..., Zip::CREATE | Zip::TRUNC) do |ar|
      # specifies compression level: ..., Zip::CREATE, Zip::BEST_SPEED) do |ar|
    
        ar.add_file('foo.txt') # add file to zip archive
    
      # add file to zip archive from File object
      ar << bar_txt # or ar.add_io(bar_txt)
    
      # add file to zip archive from buffer
      ar.add_buffer('zoo.txt', 'Hello, world!')
    end
    
    bar_txt.rewind
    
    # include directory in zip archive
    Zip::Archive.open('filename.zip') do |ar|
      ar.add_dir('dirname')
      ar.add_file('dirname/foo.txt', 'foo.txt')
          # args: <entry name>     ,  <source>
    
      ar.add_io('dirname/bar.txt', bar_txt)
        # args: <entry name>     , <source>
    
      ar.add_buffer('dirname/zoo.txt', 'Hello, world!')
            # args: <entry name>     , <source>
    end
    
    bar_txt.close # close file after archive closed
    
    # add huge file
    source = %w(London Bridge is falling down)
    
    Zip::Archive.open('filename.zip') do |ar|
      # lb.txt => 'LondonBridgeisfallingdown'
      ar.add('lb.txt') do # add(<filename>, <mtime>)
        source.shift # end of stream is nil
      end
    end

=== modifying zip archive

    require 'zipruby'
    
    bar_txt = open('bar.txt')
    
    Zip::Archive.open('filename.zip') do |ar|
      # replace file in zip archive
      ar.replace_file(0, 'foo.txt')
    
      # replace file in zip archive with File object
      ar.replace_io(1, bar_txt)
    
      # if commit changes
      # ar.commit
    
      # replace file in zip archive with buffer
      ar.replace_buffer(2, 'Hello, world!')
      # or
      # ar.replace_buffer('entry name', 'Hello, world!')
      # if ignore case distinctions 
      # ar.replace_buffer('entry name', 'Hello, world!', Zip::FL_NOCASE)
      
      # add or replace file in zip archive
      ar.add_or_replace_file('zoo.txt', 'foo.txt')
    end
    
    # append comment    
    Zip::Archive.open('filename.zip') do |ar|
      ar.comment = <<-EOS
        jugem jugem gokou no surikere
        kaijari suigyo no
        suigyoumatsu unraimatsu furaimatsu
      EOS
    end
    
    bar_txt.close # close file after archive closed
    
    # ar1 import ar2 entries
    Zip::Archive.open('ar1.zip') do |ar1|
      Zip::Archive.open('ar2.zip') do |ar2|
        ar1.update(ar2)
      end
    end

=== encrypt/decrypt zip archive

    require 'zipruby'
    
    # encrypt
    Zip::Archive.encrypt('filename.zip', 'password') # return true if encrypted
    # or
    # Zip::Archive.open('filename.zip') do |ar|
    #   ar.encrypt('password')
    # end
    
    # decrypt
    Zip::Archive.decrypt('filename.zip', 'password') # return true if decrypted
    # or
    # Zip::Archive.open('filename.zip') do |ar|
    #   ar.decrypt('password')
    # end

=== modifying zip data in memory

    require 'zipruby'
    
    $stdout.binmode
    
    buf = ''
    
    Zip::Archive.open_buffer(buf, Zip::CREATE) do |ar|
      ar.add_buffer('bar.txt', 'zoo');
    end

    buf2 = Zip::Archive.open_buffer(Zip::CREATE) do |ar|
      ar.add_buffer('bar.txt', 'zoo');
    end
    
    Zip::Archive.open_buffer(buf) do |ar|
      ar.each do |f|
        puts f.name
      end
    end
    
    # read from stream
    zip_data = open('foo.zip') do |f|
      f.binmode
      f.read
    end
    
    stream = lambda { return zip_data.slice!(0, 256) }
    
    Zip::Archive.open_buffer(stream) do |ar|
      puts ar.num_files
    end
    
    # output huge zip data to stdout
    Zip::Archive.open_buffer(zip_data) do |ar|
      ar.read do |chunk|
        print chunk
      end
    end

=== adding directory recursively

    require 'zipruby'
    
    Zip::Archive.open('filename.zip', Zip::CREATE) do |ar|
      ar.add_dir('dir')
    
      Dir.glob('dir/**/*').each do |path|
        if File.directory?(path)
          ar.add_dir(path)
        else
          ar.add_file(path, path) # add_file(<entry name>, <source path>)
        end
      end
    end

=== extract all files

    require 'zipruby'
    require 'fileutils'
    
    Zip::Archive.open('filename.zip') do |ar|
      ar.each do |zf|
        if zf.directory?
          FileUtils.mkdir_p(zf.name)
        else
          dirname = File.dirname(zf.name)
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
    
          open(zf.name, 'wb') do |f|
            f << zf.read
          end
        end
      end
    end

== License

    Copyright (c) 2008-2010 SUGAWARA Genki <sgwr_dts@yahoo.co.jp>
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:
    
        * Redistributions of source code must retain the above copyright notice, 
          this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright notice, 
          this list of conditions and the following disclaimer in the documentation 
          and/or other materials provided with the distribution.
        * The names of its contributors may not be used to endorse or promote products 
           derived from this software without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
    ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
    OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY 
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
    DAMAGE.

=== libzip

Zip/Ruby contains libzip.

libzip is a C library for reading, creating, and modifying zip archives.

* distribution site:
  * http://www.nih.at/libzip/
  * ftp.nih.at /pub/nih/libzip

* authors:
  * Dieter Baron <dillo@giga.or.at>
  * Thomas Klausner <tk@giga.or.at>
