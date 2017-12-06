
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

    var PACKAGE_PATH;
    if (typeof window === 'object') {
      PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
                              Module['locateFile'](REMOTE_PACKAGE_BASE) :
                              ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);
  
    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;
  
    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
          var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onload = function(event) {
        var packageData = xhr.response;
        callback(packageData);
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };
  
      var fetched = null, fetchedCallback = null;
      fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, function(data) {
        if (fetchedCallback) {
          fetchedCallback(data);
          fetchedCallback = null;
        } else {
          fetched = data;
        }
      }, handleError);
    
  function runWithFS() {

    function assert(check, msg) {
      if (!check) throw msg + new Error().stack;
    }
Module['FS_createPath']('/', 'res', true, true);
Module['FS_createPath']('/res', 'sfx', true, true);
Module['FS_createPath']('/res', 'img', true, true);
Module['FS_createPath']('/res/img', 'particles', true, true);
Module['FS_createPath']('/res/img', 'pet', true, true);
Module['FS_createPath']('/res', 'font', true, true);
Module['FS_createPath']('/', 'modules', true, true);
Module['FS_createPath']('/modules', 'hump', true, true);
Module['FS_createPath']('/', 'src', true, true);
Module['FS_createPath']('/src', 'objects', true, true);
Module['FS_createPath']('/src', 'states', true, true);

    function DataRequest(start, end, crunched, audio) {
      this.start = start;
      this.end = end;
      this.crunched = crunched;
      this.audio = audio;
    }
    DataRequest.prototype = {
      requests: {},
      open: function(mode, name) {
        this.name = name;
        this.requests[name] = this;
        Module['addRunDependency']('fp ' + this.name);
      },
      send: function() {},
      onload: function() {
        var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

      },
      finish: function(byteArray) {
        var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      },
    };

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
        }

  
    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;
      
        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);
  
          var files = metadata.files;
          for (i = 0; i < files.length; ++i) {
            DataRequest.prototype.requests[files[i].filename].onload();
          }
              Module['removeRunDependency']('datafile_game.data');

    };
    Module['addRunDependency']('datafile_game.data');
  
    if (!Module.preloadResults) Module.preloadResults = {};
  
      Module.preloadResults[PACKAGE_NAME] = {fromCache: false};
      if (fetched) {
        processPackageData(fetched);
        fetched = null;
      } else {
        fetchedCallback = processPackageData;
      }
    
  }
  if (Module['calledRun']) {
    runWithFS();
  } else {
    if (!Module['preRun']) Module['preRun'] = [];
    Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
  }

 }
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 6148, "filename": "/.DS_Store"}, {"audio": 0, "start": 6148, "crunched": 0, "end": 7521, "filename": "/main.lua"}, {"audio": 0, "start": 7521, "crunched": 0, "end": 7765, "filename": "/conf.lua"}, {"audio": 1, "start": 7765, "crunched": 0, "end": 24193, "filename": "/res/sfx/dragon.wav"}, {"audio": 1, "start": 24193, "crunched": 0, "end": 44887, "filename": "/res/sfx/die.wav"}, {"audio": 1, "start": 44887, "crunched": 0, "end": 58095, "filename": "/res/sfx/thud2.wav"}, {"audio": 1, "start": 58095, "crunched": 0, "end": 75855, "filename": "/res/sfx/fireball_shoot.wav"}, {"audio": 1, "start": 75855, "crunched": 0, "end": 84091, "filename": "/res/sfx/mollusk.wav"}, {"audio": 1, "start": 84091, "crunched": 0, "end": 109311, "filename": "/res/sfx/fireball_hit.wav"}, {"audio": 1, "start": 109311, "crunched": 0, "end": 123938, "filename": "/res/sfx/pop.mp3"}, {"audio": 1, "start": 123938, "crunched": 0, "end": 132174, "filename": "/res/sfx/ferro.wav"}, {"audio": 1, "start": 132174, "crunched": 0, "end": 147632, "filename": "/res/sfx/amanita.wav"}, {"audio": 1, "start": 147632, "crunched": 0, "end": 177933, "filename": "/res/sfx/thud1.mp3"}, {"audio": 1, "start": 177933, "crunched": 0, "end": 193413, "filename": "/res/sfx/lumpy.wav"}, {"audio": 1, "start": 193413, "crunched": 0, "end": 213937, "filename": "/res/sfx/chin.wav"}, {"audio": 1, "start": 213937, "crunched": 0, "end": 230365, "filename": "/res/sfx/dasher.wav"}, {"audio": 0, "start": 230365, "crunched": 0, "end": 230572, "filename": "/res/img/lava.png"}, {"audio": 0, "start": 230572, "crunched": 0, "end": 230714, "filename": "/res/img/cursor.png"}, {"audio": 0, "start": 230714, "crunched": 0, "end": 230853, "filename": "/res/img/time.png"}, {"audio": 0, "start": 230853, "crunched": 0, "end": 231011, "filename": "/res/img/boundary.png"}, {"audio": 0, "start": 231011, "crunched": 0, "end": 231098, "filename": "/res/img/tongue_body.png"}, {"audio": 0, "start": 231098, "crunched": 0, "end": 231939, "filename": "/res/img/closed.png"}, {"audio": 0, "start": 231939, "crunched": 0, "end": 232044, "filename": "/res/img/tongue_tip.png"}, {"audio": 0, "start": 232044, "crunched": 0, "end": 232335, "filename": "/res/img/apple_crate.png"}, {"audio": 0, "start": 232335, "crunched": 0, "end": 232464, "filename": "/res/img/cursor_drag.png"}, {"audio": 0, "start": 232464, "crunched": 0, "end": 232598, "filename": "/res/img/heart.png"}, {"audio": 0, "start": 232598, "crunched": 0, "end": 232716, "filename": "/res/img/exclamation.png"}, {"audio": 0, "start": 232716, "crunched": 0, "end": 232904, "filename": "/res/img/apple.png"}, {"audio": 0, "start": 232904, "crunched": 0, "end": 233162, "filename": "/res/img/grass.png"}, {"audio": 0, "start": 233162, "crunched": 0, "end": 237586, "filename": "/res/img/logo.png"}, {"audio": 0, "start": 237586, "crunched": 0, "end": 237755, "filename": "/res/img/tombstone.png"}, {"audio": 0, "start": 237755, "crunched": 0, "end": 238053, "filename": "/res/img/nest.png"}, {"audio": 0, "start": 238053, "crunched": 0, "end": 238190, "filename": "/res/img/pet.png"}, {"audio": 0, "start": 238190, "crunched": 0, "end": 238386, "filename": "/res/img/fireball.png"}, {"audio": 0, "start": 238386, "crunched": 0, "end": 238650, "filename": "/res/img/egg.png"}, {"audio": 0, "start": 238650, "crunched": 0, "end": 238792, "filename": "/res/img/coin.png"}, {"audio": 0, "start": 238792, "crunched": 0, "end": 239254, "filename": "/res/img/particles/dust.png"}, {"audio": 0, "start": 239254, "crunched": 0, "end": 239405, "filename": "/res/img/particles/apple.png"}, {"audio": 0, "start": 239405, "crunched": 0, "end": 239505, "filename": "/res/img/particles/tears.png"}, {"audio": 0, "start": 239505, "crunched": 0, "end": 240476, "filename": "/res/img/particles/explosion.png"}, {"audio": 0, "start": 240476, "crunched": 0, "end": 240724, "filename": "/res/img/pet/dasher_sad.png"}, {"audio": 0, "start": 240724, "crunched": 0, "end": 240953, "filename": "/res/img/pet/mollusk.png"}, {"audio": 0, "start": 240953, "crunched": 0, "end": 241178, "filename": "/res/img/pet/amanita_sad.png"}, {"audio": 0, "start": 241178, "crunched": 0, "end": 241413, "filename": "/res/img/pet/ferro.png"}, {"audio": 0, "start": 241413, "crunched": 0, "end": 241690, "filename": "/res/img/pet/lumpy_scared.png"}, {"audio": 0, "start": 241690, "crunched": 0, "end": 241934, "filename": "/res/img/pet/chin_eat.png"}, {"audio": 0, "start": 241934, "crunched": 0, "end": 242177, "filename": "/res/img/pet/dragon.png"}, {"audio": 0, "start": 242177, "crunched": 0, "end": 242395, "filename": "/res/img/pet/amanita_happy.png"}, {"audio": 0, "start": 242395, "crunched": 0, "end": 242628, "filename": "/res/img/pet/dasher_happy.png"}, {"audio": 0, "start": 242628, "crunched": 0, "end": 242852, "filename": "/res/img/pet/dasher.png"}, {"audio": 0, "start": 242852, "crunched": 0, "end": 243076, "filename": "/res/img/pet/chin.png"}, {"audio": 0, "start": 243076, "crunched": 0, "end": 243285, "filename": "/res/img/pet/amanita.png"}, {"audio": 0, "start": 243285, "crunched": 0, "end": 243509, "filename": "/res/img/pet/lumpy.png"}, {"audio": 0, "start": 243509, "crunched": 0, "end": 243625, "filename": "/res/img/pet/default.png"}, {"audio": 0, "start": 243625, "crunched": 0, "end": 243864, "filename": "/res/img/pet/ferro_sad.png"}, {"audio": 0, "start": 243864, "crunched": 0, "end": 293296, "filename": "/res/font/redalert.ttf"}, {"audio": 0, "start": 293296, "crunched": 0, "end": 296362, "filename": "/modules/hump/class.lua"}, {"audio": 0, "start": 296362, "crunched": 0, "end": 299895, "filename": "/modules/hump/gamestate.lua"}, {"audio": 0, "start": 299895, "crunched": 0, "end": 302557, "filename": "/modules/hump/signal.lua"}, {"audio": 0, "start": 302557, "crunched": 0, "end": 308535, "filename": "/modules/hump/vector.lua"}, {"audio": 0, "start": 308535, "crunched": 0, "end": 315068, "filename": "/modules/hump/timer.lua"}, {"audio": 0, "start": 315068, "crunched": 0, "end": 319252, "filename": "/modules/hump/vector-light.lua"}, {"audio": 0, "start": 319252, "crunched": 0, "end": 325319, "filename": "/modules/hump/camera.lua"}, {"audio": 0, "start": 325319, "crunched": 0, "end": 327140, "filename": "/src/Container.lua"}, {"audio": 0, "start": 327140, "crunched": 0, "end": 328684, "filename": "/src/Particles.lua"}, {"audio": 0, "start": 328684, "crunched": 0, "end": 330134, "filename": "/src/Animation.lua"}, {"audio": 0, "start": 330134, "crunched": 0, "end": 330298, "filename": "/src/Constants.lua"}, {"audio": 0, "start": 330298, "crunched": 0, "end": 331351, "filename": "/src/Object.lua"}, {"audio": 0, "start": 331351, "crunched": 0, "end": 332121, "filename": "/src/Squishable.lua"}, {"audio": 0, "start": 332121, "crunched": 0, "end": 332936, "filename": "/src/Sounds.lua"}, {"audio": 0, "start": 332936, "crunched": 0, "end": 335669, "filename": "/src/Sprites.lua"}, {"audio": 0, "start": 335669, "crunched": 0, "end": 336848, "filename": "/src/objects/Lava.lua"}, {"audio": 0, "start": 336848, "crunched": 0, "end": 339101, "filename": "/src/objects/PetLumpy.lua"}, {"audio": 0, "start": 339101, "crunched": 0, "end": 339907, "filename": "/src/objects/PetMollusk.lua"}, {"audio": 0, "start": 339907, "crunched": 0, "end": 341787, "filename": "/src/objects/PetDasher.lua"}, {"audio": 0, "start": 341787, "crunched": 0, "end": 342856, "filename": "/src/objects/Boundary.lua"}, {"audio": 0, "start": 342856, "crunched": 0, "end": 345197, "filename": "/src/objects/PetChin.lua"}, {"audio": 0, "start": 345197, "crunched": 0, "end": 346528, "filename": "/src/objects/Grass.lua"}, {"audio": 0, "start": 346528, "crunched": 0, "end": 347837, "filename": "/src/objects/Apple.lua"}, {"audio": 0, "start": 347837, "crunched": 0, "end": 349537, "filename": "/src/objects/WanderingPet.lua"}, {"audio": 0, "start": 349537, "crunched": 0, "end": 350500, "filename": "/src/objects/Selectable.lua"}, {"audio": 0, "start": 350500, "crunched": 0, "end": 351666, "filename": "/src/objects/Tombstone.lua"}, {"audio": 0, "start": 351666, "crunched": 0, "end": 352876, "filename": "/src/objects/Nest.lua"}, {"audio": 0, "start": 352876, "crunched": 0, "end": 357742, "filename": "/src/objects/Pet.lua"}, {"audio": 0, "start": 357742, "crunched": 0, "end": 359262, "filename": "/src/objects/Fireball.lua"}, {"audio": 0, "start": 359262, "crunched": 0, "end": 360376, "filename": "/src/objects/Egg.lua"}, {"audio": 0, "start": 360376, "crunched": 0, "end": 362006, "filename": "/src/objects/PetAmanita.lua"}, {"audio": 0, "start": 362006, "crunched": 0, "end": 363391, "filename": "/src/objects/PetDragon.lua"}, {"audio": 0, "start": 363391, "crunched": 0, "end": 364921, "filename": "/src/objects/AppleCrate.lua"}, {"audio": 0, "start": 364921, "crunched": 0, "end": 365802, "filename": "/src/objects/PetFerro.lua"}, {"audio": 0, "start": 365802, "crunched": 0, "end": 366717, "filename": "/src/states/Title.lua"}, {"audio": 0, "start": 366717, "crunched": 0, "end": 376020, "filename": "/src/states/Game.lua"}, {"audio": 0, "start": 376020, "crunched": 0, "end": 377793, "filename": "/src/states/Results.lua"}, {"audio": 0, "start": 377793, "crunched": 0, "end": 379382, "filename": "/src/states/Instructions.lua"}], "remote_package_size": 379382, "package_uuid": "e70c4386-6ae0-423d-8d54-86d2ed96af9c"});

})();
