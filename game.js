
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
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 1373, "filename": "/main.lua"}, {"audio": 0, "start": 1373, "crunched": 0, "end": 1617, "filename": "/conf.lua"}, {"audio": 1, "start": 1617, "crunched": 0, "end": 18045, "filename": "/res/sfx/dragon.wav"}, {"audio": 1, "start": 18045, "crunched": 0, "end": 38739, "filename": "/res/sfx/die.wav"}, {"audio": 1, "start": 38739, "crunched": 0, "end": 51947, "filename": "/res/sfx/thud2.wav"}, {"audio": 1, "start": 51947, "crunched": 0, "end": 69707, "filename": "/res/sfx/fireball_shoot.wav"}, {"audio": 1, "start": 69707, "crunched": 0, "end": 77943, "filename": "/res/sfx/mollusk.wav"}, {"audio": 1, "start": 77943, "crunched": 0, "end": 103163, "filename": "/res/sfx/fireball_hit.wav"}, {"audio": 1, "start": 103163, "crunched": 0, "end": 117790, "filename": "/res/sfx/pop.mp3"}, {"audio": 1, "start": 117790, "crunched": 0, "end": 126026, "filename": "/res/sfx/ferro.wav"}, {"audio": 1, "start": 126026, "crunched": 0, "end": 141484, "filename": "/res/sfx/amanita.wav"}, {"audio": 1, "start": 141484, "crunched": 0, "end": 171785, "filename": "/res/sfx/thud1.mp3"}, {"audio": 1, "start": 171785, "crunched": 0, "end": 187265, "filename": "/res/sfx/lumpy.wav"}, {"audio": 1, "start": 187265, "crunched": 0, "end": 207789, "filename": "/res/sfx/chin.wav"}, {"audio": 1, "start": 207789, "crunched": 0, "end": 224217, "filename": "/res/sfx/dasher.wav"}, {"audio": 0, "start": 224217, "crunched": 0, "end": 224424, "filename": "/res/img/lava.png"}, {"audio": 0, "start": 224424, "crunched": 0, "end": 224566, "filename": "/res/img/cursor.png"}, {"audio": 0, "start": 224566, "crunched": 0, "end": 225032, "filename": "/res/img/joy.png"}, {"audio": 0, "start": 225032, "crunched": 0, "end": 225171, "filename": "/res/img/time.png"}, {"audio": 0, "start": 225171, "crunched": 0, "end": 225329, "filename": "/res/img/boundary.png"}, {"audio": 0, "start": 225329, "crunched": 0, "end": 225416, "filename": "/res/img/tongue_body.png"}, {"audio": 0, "start": 225416, "crunched": 0, "end": 226257, "filename": "/res/img/closed.png"}, {"audio": 0, "start": 226257, "crunched": 0, "end": 226437, "filename": "/res/img/warn_food.png"}, {"audio": 0, "start": 226437, "crunched": 0, "end": 226542, "filename": "/res/img/tongue_tip.png"}, {"audio": 0, "start": 226542, "crunched": 0, "end": 226833, "filename": "/res/img/apple_crate.png"}, {"audio": 0, "start": 226833, "crunched": 0, "end": 226962, "filename": "/res/img/cursor_drag.png"}, {"audio": 0, "start": 226962, "crunched": 0, "end": 227096, "filename": "/res/img/heart.png"}, {"audio": 0, "start": 227096, "crunched": 0, "end": 227214, "filename": "/res/img/exclamation.png"}, {"audio": 0, "start": 227214, "crunched": 0, "end": 227396, "filename": "/res/img/warn_move.png"}, {"audio": 0, "start": 227396, "crunched": 0, "end": 227584, "filename": "/res/img/apple.png"}, {"audio": 0, "start": 227584, "crunched": 0, "end": 227842, "filename": "/res/img/grass.png"}, {"audio": 0, "start": 227842, "crunched": 0, "end": 232266, "filename": "/res/img/logo.png"}, {"audio": 0, "start": 232266, "crunched": 0, "end": 232435, "filename": "/res/img/tombstone.png"}, {"audio": 0, "start": 232435, "crunched": 0, "end": 232572, "filename": "/res/img/pet.png"}, {"audio": 0, "start": 232572, "crunched": 0, "end": 232768, "filename": "/res/img/fireball.png"}, {"audio": 0, "start": 232768, "crunched": 0, "end": 233032, "filename": "/res/img/egg.png"}, {"audio": 0, "start": 233032, "crunched": 0, "end": 233213, "filename": "/res/img/warn_group.png"}, {"audio": 0, "start": 233213, "crunched": 0, "end": 233355, "filename": "/res/img/coin.png"}, {"audio": 0, "start": 233355, "crunched": 0, "end": 233817, "filename": "/res/img/particles/dust.png"}, {"audio": 0, "start": 233817, "crunched": 0, "end": 233968, "filename": "/res/img/particles/apple.png"}, {"audio": 0, "start": 233968, "crunched": 0, "end": 234068, "filename": "/res/img/particles/tears.png"}, {"audio": 0, "start": 234068, "crunched": 0, "end": 234316, "filename": "/res/img/pet/dasher_sad.png"}, {"audio": 0, "start": 234316, "crunched": 0, "end": 234545, "filename": "/res/img/pet/mollusk.png"}, {"audio": 0, "start": 234545, "crunched": 0, "end": 234770, "filename": "/res/img/pet/amanita_sad.png"}, {"audio": 0, "start": 234770, "crunched": 0, "end": 235005, "filename": "/res/img/pet/ferro.png"}, {"audio": 0, "start": 235005, "crunched": 0, "end": 235282, "filename": "/res/img/pet/lumpy_scared.png"}, {"audio": 0, "start": 235282, "crunched": 0, "end": 235526, "filename": "/res/img/pet/chin_eat.png"}, {"audio": 0, "start": 235526, "crunched": 0, "end": 235769, "filename": "/res/img/pet/dragon.png"}, {"audio": 0, "start": 235769, "crunched": 0, "end": 235987, "filename": "/res/img/pet/amanita_happy.png"}, {"audio": 0, "start": 235987, "crunched": 0, "end": 236220, "filename": "/res/img/pet/dasher_happy.png"}, {"audio": 0, "start": 236220, "crunched": 0, "end": 236444, "filename": "/res/img/pet/dasher.png"}, {"audio": 0, "start": 236444, "crunched": 0, "end": 236668, "filename": "/res/img/pet/chin.png"}, {"audio": 0, "start": 236668, "crunched": 0, "end": 236877, "filename": "/res/img/pet/amanita.png"}, {"audio": 0, "start": 236877, "crunched": 0, "end": 237101, "filename": "/res/img/pet/lumpy.png"}, {"audio": 0, "start": 237101, "crunched": 0, "end": 237217, "filename": "/res/img/pet/default.png"}, {"audio": 0, "start": 237217, "crunched": 0, "end": 237456, "filename": "/res/img/pet/ferro_sad.png"}, {"audio": 0, "start": 237456, "crunched": 0, "end": 286888, "filename": "/res/font/redalert.ttf"}, {"audio": 0, "start": 286888, "crunched": 0, "end": 289954, "filename": "/modules/hump/class.lua"}, {"audio": 0, "start": 289954, "crunched": 0, "end": 293487, "filename": "/modules/hump/gamestate.lua"}, {"audio": 0, "start": 293487, "crunched": 0, "end": 296149, "filename": "/modules/hump/signal.lua"}, {"audio": 0, "start": 296149, "crunched": 0, "end": 302127, "filename": "/modules/hump/vector.lua"}, {"audio": 0, "start": 302127, "crunched": 0, "end": 308660, "filename": "/modules/hump/timer.lua"}, {"audio": 0, "start": 308660, "crunched": 0, "end": 312844, "filename": "/modules/hump/vector-light.lua"}, {"audio": 0, "start": 312844, "crunched": 0, "end": 318911, "filename": "/modules/hump/camera.lua"}, {"audio": 0, "start": 318911, "crunched": 0, "end": 320732, "filename": "/src/Container.lua"}, {"audio": 0, "start": 320732, "crunched": 0, "end": 322035, "filename": "/src/Particles.lua"}, {"audio": 0, "start": 322035, "crunched": 0, "end": 323485, "filename": "/src/Animation.lua"}, {"audio": 0, "start": 323485, "crunched": 0, "end": 323649, "filename": "/src/Constants.lua"}, {"audio": 0, "start": 323649, "crunched": 0, "end": 324702, "filename": "/src/Object.lua"}, {"audio": 0, "start": 324702, "crunched": 0, "end": 325300, "filename": "/src/Squishable.lua"}, {"audio": 0, "start": 325300, "crunched": 0, "end": 326115, "filename": "/src/Sounds.lua"}, {"audio": 0, "start": 326115, "crunched": 0, "end": 328710, "filename": "/src/Sprites.lua"}, {"audio": 0, "start": 328710, "crunched": 0, "end": 329889, "filename": "/src/objects/Lava.lua"}, {"audio": 0, "start": 329889, "crunched": 0, "end": 332142, "filename": "/src/objects/PetLumpy.lua"}, {"audio": 0, "start": 332142, "crunched": 0, "end": 332948, "filename": "/src/objects/PetMollusk.lua"}, {"audio": 0, "start": 332948, "crunched": 0, "end": 334828, "filename": "/src/objects/PetDasher.lua"}, {"audio": 0, "start": 334828, "crunched": 0, "end": 335897, "filename": "/src/objects/Boundary.lua"}, {"audio": 0, "start": 335897, "crunched": 0, "end": 338238, "filename": "/src/objects/PetChin.lua"}, {"audio": 0, "start": 338238, "crunched": 0, "end": 339569, "filename": "/src/objects/Grass.lua"}, {"audio": 0, "start": 339569, "crunched": 0, "end": 340620, "filename": "/src/objects/Apple.lua"}, {"audio": 0, "start": 340620, "crunched": 0, "end": 342320, "filename": "/src/objects/WanderingPet.lua"}, {"audio": 0, "start": 342320, "crunched": 0, "end": 343283, "filename": "/src/objects/Selectable.lua"}, {"audio": 0, "start": 343283, "crunched": 0, "end": 344449, "filename": "/src/objects/Tombstone.lua"}, {"audio": 0, "start": 344449, "crunched": 0, "end": 349315, "filename": "/src/objects/Pet.lua"}, {"audio": 0, "start": 349315, "crunched": 0, "end": 350835, "filename": "/src/objects/Fireball.lua"}, {"audio": 0, "start": 350835, "crunched": 0, "end": 352667, "filename": "/src/objects/Egg.lua"}, {"audio": 0, "start": 352667, "crunched": 0, "end": 354297, "filename": "/src/objects/PetAmanita.lua"}, {"audio": 0, "start": 354297, "crunched": 0, "end": 355682, "filename": "/src/objects/PetDragon.lua"}, {"audio": 0, "start": 355682, "crunched": 0, "end": 357466, "filename": "/src/objects/AppleCrate.lua"}, {"audio": 0, "start": 357466, "crunched": 0, "end": 358347, "filename": "/src/objects/PetFerro.lua"}, {"audio": 0, "start": 358347, "crunched": 0, "end": 359216, "filename": "/src/states/Title.lua"}, {"audio": 0, "start": 359216, "crunched": 0, "end": 366677, "filename": "/src/states/Game.lua"}, {"audio": 0, "start": 366677, "crunched": 0, "end": 368445, "filename": "/src/states/Results.lua"}, {"audio": 0, "start": 368445, "crunched": 0, "end": 370035, "filename": "/src/states/Instructions.lua"}], "remote_package_size": 370035, "package_uuid": "c359d5bb-8d1e-4445-8d48-dee312c9c439"});

})();
