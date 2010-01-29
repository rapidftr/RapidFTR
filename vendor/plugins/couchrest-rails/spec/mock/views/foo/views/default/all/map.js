function(doc) {
  emit(doc.created_at, {
    title : doc.title,
    body : doc.body,
    created_at : doc.created_at
  });
};