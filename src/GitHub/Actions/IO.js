const { mkdir } = require('fs/promises');

exports._mkdirP = (path) => mkdir(path, { recursive: true });
