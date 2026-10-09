export 'photo_file_store_memory.dart'
    if (dart.library.io) 'photo_file_store_native.dart'
    show createPhotoFileStore;
