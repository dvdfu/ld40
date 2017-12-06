
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
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 1373, "filename": "/main.lua"}, {"audio": 0, "start": 1373, "crunched": 0, "end": 1617, "filename": "/conf.lua"}, {"audio": 1, "start": 1617, "crunched": 0, "end": 18045, "filename": "/res/sfx/dragon.wav"}, {"audio": 1, "start": 18045, "crunched": 0, "end": 38739, "filename": "/res/sfx/die.wav"}, {"audio": 1, "start": 38739, "crunched": 0, "end": 51947, "filename": "/res/sfx/thud2.wav"}, {"audio": 1, "start": 51947, "crunched": 0, "end": 69707, "filename": "/res/sfx/fireball_shoot.wav"}, {"audio": 1, "start": 69707, "crunched": 0, "end": 77943, "filename": "/res/sfx/mollusk.wav"}, {"audio": 1, "start": 77943, "crunched": 0, "end": 103163, "filename": "/res/sfx/fireball_hit.wav"}, {"audio": 1, "start": 103163, "crunched": 0, "end": 117790, "filename": "/res/sfx/pop.mp3"}, {"audio": 1, "start": 117790, "crunched": 0, "end": 126026, "filename": "/res/sfx/ferro.wav"}, {"audio": 1, "start": 126026, "crunched": 0, "end": 141484, "filename": "/res/sfx/amanita.wav"}, {"audio": 1, "start": 141484, "crunched": 0, "end": 171785, "filename": "/res/sfx/thud1.mp3"}, {"audio": 1, "start": 171785, "crunched": 0, "end": 187265, "filename": "/res/sfx/lumpy.wav"}, {"audio": 1, "start": 187265, "crunched": 0, "end": 207789, "filename": "/res/sfx/chin.wav"}, {"audio": 1, "start": 207789, "crunched": 0, "end": 224217, "filename": "/res/sfx/dasher.wav"}, {"audio": 0, "start": 224217, "crunched": 0, "end": 224424, "filename": "/res/img/lava.png"}, {"audio": 0, "start": 224424, "crunched": 0, "end": 224566, "filename": "/res/img/cursor.png"}, {"audio": 0, "start": 224566, "crunched": 0, "end": 225032, "filename": "/res/img/joy.png"}, {"audio": 0, "start": 225032, "crunched": 0, "end": 225171, "filename": "/res/img/time.png"}, {"audio": 0, "start": 225171, "crunched": 0, "end": 225329, "filename": "/res/img/boundary.png"}, {"audio": 0, "start": 225329, "crunched": 0, "end": 225416, "filename": "/res/img/tongue_body.png"}, {"audio": 0, "start": 225416, "crunched": 0, "end": 226257, "filename": "/res/img/closed.png"}, {"audio": 0, "start": 226257, "crunched": 0, "end": 226437, "filename": "/res/img/warn_food.png"}, {"audio": 0, "start": 226437, "crunched": 0, "end": 226542, "filename": "/res/img/tongue_tip.png"}, {"audio": 0, "start": 226542, "crunched": 0, "end": 226833, "filename": "/res/img/apple_crate.png"}, {"audio": 0, "start": 226833, "crunched": 0, "end": 226962, "filename": "/res/img/cursor_drag.png"}, {"audio": 0, "start": 226962, "crunched": 0, "end": 227096, "filename": "/res/img/heart.png"}, {"audio": 0, "start": 227096, "crunched": 0, "end": 227214, "filename": "/res/img/exclamation.png"}, {"audio": 0, "start": 227214, "crunched": 0, "end": 227396, "filename": "/res/img/warn_move.png"}, {"audio": 0, "start": 227396, "crunched": 0, "end": 227584, "filename": "/res/img/apple.png"}, {"audio": 0, "start": 227584, "crunched": 0, "end": 227842, "filename": "/res/img/grass.png"}, {"audio": 0, "start": 227842, "crunched": 0, "end": 232266, "filename": "/res/img/logo.png"}, {"audio": 0, "start": 232266, "crunched": 0, "end": 232435, "filename": "/res/img/tombstone.png"}, {"audio": 0, "start": 232435, "crunched": 0, "end": 232733, "filename": "/res/img/nest.png"}, {"audio": 0, "start": 232733, "crunched": 0, "end": 232870, "filename": "/res/img/pet.png"}, {"audio": 0, "start": 232870, "crunched": 0, "end": 233066, "filename": "/res/img/fireball.png"}, {"audio": 0, "start": 233066, "crunched": 0, "end": 233330, "filename": "/res/img/egg.png"}, {"audio": 0, "start": 233330, "crunched": 0, "end": 233511, "filename": "/res/img/warn_group.png"}, {"audio": 0, "start": 233511, "crunched": 0, "end": 233653, "filename": "/res/img/coin.png"}, {"audio": 0, "start": 233653, "crunched": 0, "end": 234115, "filename": "/res/img/particles/dust.png"}, {"audio": 0, "start": 234115, "crunched": 0, "end": 234266, "filename": "/res/img/particles/apple.png"}, {"audio": 0, "start": 234266, "crunched": 0, "end": 234366, "filename": "/res/img/particles/tears.png"}, {"audio": 0, "start": 234366, "crunched": 0, "end": 235337, "filename": "/res/img/particles/explosion.png"}, {"audio": 0, "start": 235337, "crunched": 0, "end": 235585, "filename": "/res/img/pet/dasher_sad.png"}, {"audio": 0, "start": 235585, "crunched": 0, "end": 235814, "filename": "/res/img/pet/mollusk.png"}, {"audio": 0, "start": 235814, "crunched": 0, "end": 236039, "filename": "/res/img/pet/amanita_sad.png"}, {"audio": 0, "start": 236039, "crunched": 0, "end": 236274, "filename": "/res/img/pet/ferro.png"}, {"audio": 0, "start": 236274, "crunched": 0, "end": 236551, "filename": "/res/img/pet/lumpy_scared.png"}, {"audio": 0, "start": 236551, "crunched": 0, "end": 236795, "filename": "/res/img/pet/chin_eat.png"}, {"audio": 0, "start": 236795, "crunched": 0, "end": 237038, "filename": "/res/img/pet/dragon.png"}, {"audio": 0, "start": 237038, "crunched": 0, "end": 237256, "filename": "/res/img/pet/amanita_happy.png"}, {"audio": 0, "start": 237256, "crunched": 0, "end": 237489, "filename": "/res/img/pet/dasher_happy.png"}, {"audio": 0, "start": 237489, "crunched": 0, "end": 237713, "filename": "/res/img/pet/dasher.png"}, {"audio": 0, "start": 237713, "crunched": 0, "end": 237937, "filename": "/res/img/pet/chin.png"}, {"audio": 0, "start": 237937, "crunched": 0, "end": 238146, "filename": "/res/img/pet/amanita.png"}, {"audio": 0, "start": 238146, "crunched": 0, "end": 238370, "filename": "/res/img/pet/lumpy.png"}, {"audio": 0, "start": 238370, "crunched": 0, "end": 238486, "filename": "/res/img/pet/default.png"}, {"audio": 0, "start": 238486, "crunched": 0, "end": 238725, "filename": "/res/img/pet/ferro_sad.png"}, {"audio": 0, "start": 238725, "crunched": 0, "end": 288157, "filename": "/res/font/redalert.ttf"}, {"audio": 0, "start": 288157, "crunched": 0, "end": 291223, "filename": "/modules/hump/class.lua"}, {"audio": 0, "start": 291223, "crunched": 0, "end": 294756, "filename": "/modules/hump/gamestate.lua"}, {"audio": 0, "start": 294756, "crunched": 0, "end": 297418, "filename": "/modules/hump/signal.lua"}, {"audio": 0, "start": 297418, "crunched": 0, "end": 303396, "filename": "/modules/hump/vector.lua"}, {"audio": 0, "start": 303396, "crunched": 0, "end": 309929, "filename": "/modules/hump/timer.lua"}, {"audio": 0, "start": 309929, "crunched": 0, "end": 314113, "filename": "/modules/hump/vector-light.lua"}, {"audio": 0, "start": 314113, "crunched": 0, "end": 320180, "filename": "/modules/hump/camera.lua"}, {"audio": 0, "start": 320180, "crunched": 0, "end": 322001, "filename": "/src/Container.lua"}, {"audio": 0, "start": 322001, "crunched": 0, "end": 323545, "filename": "/src/Particles.lua"}, {"audio": 0, "start": 323545, "crunched": 0, "end": 324995, "filename": "/src/Animation.lua"}, {"audio": 0, "start": 324995, "crunched": 0, "end": 325159, "filename": "/src/Constants.lua"}, {"audio": 0, "start": 325159, "crunched": 0, "end": 326212, "filename": "/src/Object.lua"}, {"audio": 0, "start": 326212, "crunched": 0, "end": 326982, "filename": "/src/Squishable.lua"}, {"audio": 0, "start": 326982, "crunched": 0, "end": 327797, "filename": "/src/Sounds.lua"}, {"audio": 0, "start": 327797, "crunched": 0, "end": 330530, "filename": "/src/Sprites.lua"}, {"audio": 0, "start": 330530, "crunched": 0, "end": 331709, "filename": "/src/objects/Lava.lua"}, {"audio": 0, "start": 331709, "crunched": 0, "end": 333962, "filename": "/src/objects/PetLumpy.lua"}, {"audio": 0, "start": 333962, "crunched": 0, "end": 334768, "filename": "/src/objects/PetMollusk.lua"}, {"audio": 0, "start": 334768, "crunched": 0, "end": 336648, "filename": "/src/objects/PetDasher.lua"}, {"audio": 0, "start": 336648, "crunched": 0, "end": 337717, "filename": "/src/objects/Boundary.lua"}, {"audio": 0, "start": 337717, "crunched": 0, "end": 340058, "filename": "/src/objects/PetChin.lua"}, {"audio": 0, "start": 340058, "crunched": 0, "end": 341389, "filename": "/src/objects/Grass.lua"}, {"audio": 0, "start": 341389, "crunched": 0, "end": 342698, "filename": "/src/objects/Apple.lua"}, {"audio": 0, "start": 342698, "crunched": 0, "end": 344398, "filename": "/src/objects/WanderingPet.lua"}, {"audio": 0, "start": 344398, "crunched": 0, "end": 345361, "filename": "/src/objects/Selectable.lua"}, {"audio": 0, "start": 345361, "crunched": 0, "end": 346527, "filename": "/src/objects/Tombstone.lua"}, {"audio": 0, "start": 346527, "crunched": 0, "end": 347737, "filename": "/src/objects/Nest.lua"}, {"audio": 0, "start": 347737, "crunched": 0, "end": 352603, "filename": "/src/objects/Pet.lua"}, {"audio": 0, "start": 352603, "crunched": 0, "end": 354123, "filename": "/src/objects/Fireball.lua"}, {"audio": 0, "start": 354123, "crunched": 0, "end": 355237, "filename": "/src/objects/Egg.lua"}, {"audio": 0, "start": 355237, "crunched": 0, "end": 356867, "filename": "/src/objects/PetAmanita.lua"}, {"audio": 0, "start": 356867, "crunched": 0, "end": 358252, "filename": "/src/objects/PetDragon.lua"}, {"audio": 0, "start": 358252, "crunched": 0, "end": 359782, "filename": "/src/objects/AppleCrate.lua"}, {"audio": 0, "start": 359782, "crunched": 0, "end": 360663, "filename": "/src/objects/PetFerro.lua"}, {"audio": 0, "start": 360663, "crunched": 0, "end": 361540, "filename": "/src/states/Title.lua"}, {"audio": 0, "start": 361540, "crunched": 0, "end": 370844, "filename": "/src/states/Game.lua"}, {"audio": 0, "start": 370844, "crunched": 0, "end": 372617, "filename": "/src/states/Results.lua"}, {"audio": 0, "start": 372617, "crunched": 0, "end": 374206, "filename": "/src/states/Instructions.lua"}], "remote_package_size": 374206, "package_uuid": "10c7c2c8-8b79-4e6f-a89c-e5dfc2b52bcb"});

})();
