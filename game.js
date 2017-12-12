
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
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 6148, "filename": "/.DS_Store"}, {"audio": 0, "start": 6148, "crunched": 0, "end": 7791, "filename": "/main.lua"}, {"audio": 0, "start": 7791, "crunched": 0, "end": 8035, "filename": "/conf.lua"}, {"audio": 1, "start": 8035, "crunched": 0, "end": 24463, "filename": "/res/sfx/dragon.wav"}, {"audio": 1, "start": 24463, "crunched": 0, "end": 45157, "filename": "/res/sfx/die.wav"}, {"audio": 1, "start": 45157, "crunched": 0, "end": 58365, "filename": "/res/sfx/thud2.wav"}, {"audio": 1, "start": 58365, "crunched": 0, "end": 76125, "filename": "/res/sfx/fireball_shoot.wav"}, {"audio": 1, "start": 76125, "crunched": 0, "end": 84361, "filename": "/res/sfx/mollusk.wav"}, {"audio": 1, "start": 84361, "crunched": 0, "end": 109581, "filename": "/res/sfx/fireball_hit.wav"}, {"audio": 1, "start": 109581, "crunched": 0, "end": 124208, "filename": "/res/sfx/pop.mp3"}, {"audio": 1, "start": 124208, "crunched": 0, "end": 132444, "filename": "/res/sfx/ferro.wav"}, {"audio": 1, "start": 132444, "crunched": 0, "end": 147902, "filename": "/res/sfx/amanita.wav"}, {"audio": 1, "start": 147902, "crunched": 0, "end": 178203, "filename": "/res/sfx/thud1.mp3"}, {"audio": 1, "start": 178203, "crunched": 0, "end": 193683, "filename": "/res/sfx/lumpy.wav"}, {"audio": 1, "start": 193683, "crunched": 0, "end": 214207, "filename": "/res/sfx/chin.wav"}, {"audio": 1, "start": 214207, "crunched": 0, "end": 230635, "filename": "/res/sfx/dasher.wav"}, {"audio": 0, "start": 230635, "crunched": 0, "end": 230842, "filename": "/res/img/lava.png"}, {"audio": 0, "start": 230842, "crunched": 0, "end": 230984, "filename": "/res/img/cursor.png"}, {"audio": 0, "start": 230984, "crunched": 0, "end": 231123, "filename": "/res/img/time.png"}, {"audio": 0, "start": 231123, "crunched": 0, "end": 231281, "filename": "/res/img/boundary.png"}, {"audio": 0, "start": 231281, "crunched": 0, "end": 231368, "filename": "/res/img/tongue_body.png"}, {"audio": 0, "start": 231368, "crunched": 0, "end": 232209, "filename": "/res/img/closed.png"}, {"audio": 0, "start": 232209, "crunched": 0, "end": 232314, "filename": "/res/img/tongue_tip.png"}, {"audio": 0, "start": 232314, "crunched": 0, "end": 232605, "filename": "/res/img/apple_crate.png"}, {"audio": 0, "start": 232605, "crunched": 0, "end": 232734, "filename": "/res/img/cursor_drag.png"}, {"audio": 0, "start": 232734, "crunched": 0, "end": 232868, "filename": "/res/img/heart.png"}, {"audio": 0, "start": 232868, "crunched": 0, "end": 232986, "filename": "/res/img/exclamation.png"}, {"audio": 0, "start": 232986, "crunched": 0, "end": 233174, "filename": "/res/img/apple.png"}, {"audio": 0, "start": 233174, "crunched": 0, "end": 233432, "filename": "/res/img/grass.png"}, {"audio": 0, "start": 233432, "crunched": 0, "end": 237856, "filename": "/res/img/logo.png"}, {"audio": 0, "start": 237856, "crunched": 0, "end": 238025, "filename": "/res/img/tombstone.png"}, {"audio": 0, "start": 238025, "crunched": 0, "end": 238323, "filename": "/res/img/nest.png"}, {"audio": 0, "start": 238323, "crunched": 0, "end": 238460, "filename": "/res/img/pet.png"}, {"audio": 0, "start": 238460, "crunched": 0, "end": 238656, "filename": "/res/img/fireball.png"}, {"audio": 0, "start": 238656, "crunched": 0, "end": 238920, "filename": "/res/img/egg.png"}, {"audio": 0, "start": 238920, "crunched": 0, "end": 239062, "filename": "/res/img/coin.png"}, {"audio": 0, "start": 239062, "crunched": 0, "end": 239524, "filename": "/res/img/particles/dust.png"}, {"audio": 0, "start": 239524, "crunched": 0, "end": 239675, "filename": "/res/img/particles/apple.png"}, {"audio": 0, "start": 239675, "crunched": 0, "end": 239775, "filename": "/res/img/particles/tears.png"}, {"audio": 0, "start": 239775, "crunched": 0, "end": 240746, "filename": "/res/img/particles/explosion.png"}, {"audio": 0, "start": 240746, "crunched": 0, "end": 240994, "filename": "/res/img/pet/dasher_sad.png"}, {"audio": 0, "start": 240994, "crunched": 0, "end": 241223, "filename": "/res/img/pet/mollusk.png"}, {"audio": 0, "start": 241223, "crunched": 0, "end": 241448, "filename": "/res/img/pet/amanita_sad.png"}, {"audio": 0, "start": 241448, "crunched": 0, "end": 241683, "filename": "/res/img/pet/ferro.png"}, {"audio": 0, "start": 241683, "crunched": 0, "end": 241960, "filename": "/res/img/pet/lumpy_scared.png"}, {"audio": 0, "start": 241960, "crunched": 0, "end": 242204, "filename": "/res/img/pet/chin_eat.png"}, {"audio": 0, "start": 242204, "crunched": 0, "end": 242447, "filename": "/res/img/pet/dragon.png"}, {"audio": 0, "start": 242447, "crunched": 0, "end": 242665, "filename": "/res/img/pet/amanita_happy.png"}, {"audio": 0, "start": 242665, "crunched": 0, "end": 242898, "filename": "/res/img/pet/dasher_happy.png"}, {"audio": 0, "start": 242898, "crunched": 0, "end": 243122, "filename": "/res/img/pet/dasher.png"}, {"audio": 0, "start": 243122, "crunched": 0, "end": 243346, "filename": "/res/img/pet/chin.png"}, {"audio": 0, "start": 243346, "crunched": 0, "end": 243555, "filename": "/res/img/pet/amanita.png"}, {"audio": 0, "start": 243555, "crunched": 0, "end": 243779, "filename": "/res/img/pet/lumpy.png"}, {"audio": 0, "start": 243779, "crunched": 0, "end": 243895, "filename": "/res/img/pet/default.png"}, {"audio": 0, "start": 243895, "crunched": 0, "end": 244134, "filename": "/res/img/pet/ferro_sad.png"}, {"audio": 0, "start": 244134, "crunched": 0, "end": 293566, "filename": "/res/font/redalert.ttf"}, {"audio": 0, "start": 293566, "crunched": 0, "end": 296632, "filename": "/modules/hump/class.lua"}, {"audio": 0, "start": 296632, "crunched": 0, "end": 300165, "filename": "/modules/hump/gamestate.lua"}, {"audio": 0, "start": 300165, "crunched": 0, "end": 302827, "filename": "/modules/hump/signal.lua"}, {"audio": 0, "start": 302827, "crunched": 0, "end": 308805, "filename": "/modules/hump/vector.lua"}, {"audio": 0, "start": 308805, "crunched": 0, "end": 315338, "filename": "/modules/hump/timer.lua"}, {"audio": 0, "start": 315338, "crunched": 0, "end": 319522, "filename": "/modules/hump/vector-light.lua"}, {"audio": 0, "start": 319522, "crunched": 0, "end": 325589, "filename": "/modules/hump/camera.lua"}, {"audio": 0, "start": 325589, "crunched": 0, "end": 327410, "filename": "/src/Container.lua"}, {"audio": 0, "start": 327410, "crunched": 0, "end": 328954, "filename": "/src/Particles.lua"}, {"audio": 0, "start": 328954, "crunched": 0, "end": 330404, "filename": "/src/Animation.lua"}, {"audio": 0, "start": 330404, "crunched": 0, "end": 330568, "filename": "/src/Constants.lua"}, {"audio": 0, "start": 330568, "crunched": 0, "end": 331621, "filename": "/src/Object.lua"}, {"audio": 0, "start": 331621, "crunched": 0, "end": 332391, "filename": "/src/Squishable.lua"}, {"audio": 0, "start": 332391, "crunched": 0, "end": 333206, "filename": "/src/Sounds.lua"}, {"audio": 0, "start": 333206, "crunched": 0, "end": 335939, "filename": "/src/Sprites.lua"}, {"audio": 0, "start": 335939, "crunched": 0, "end": 337118, "filename": "/src/objects/Lava.lua"}, {"audio": 0, "start": 337118, "crunched": 0, "end": 339371, "filename": "/src/objects/PetLumpy.lua"}, {"audio": 0, "start": 339371, "crunched": 0, "end": 340177, "filename": "/src/objects/PetMollusk.lua"}, {"audio": 0, "start": 340177, "crunched": 0, "end": 342057, "filename": "/src/objects/PetDasher.lua"}, {"audio": 0, "start": 342057, "crunched": 0, "end": 343126, "filename": "/src/objects/Boundary.lua"}, {"audio": 0, "start": 343126, "crunched": 0, "end": 345467, "filename": "/src/objects/PetChin.lua"}, {"audio": 0, "start": 345467, "crunched": 0, "end": 346798, "filename": "/src/objects/Grass.lua"}, {"audio": 0, "start": 346798, "crunched": 0, "end": 348107, "filename": "/src/objects/Apple.lua"}, {"audio": 0, "start": 348107, "crunched": 0, "end": 349807, "filename": "/src/objects/WanderingPet.lua"}, {"audio": 0, "start": 349807, "crunched": 0, "end": 350770, "filename": "/src/objects/Selectable.lua"}, {"audio": 0, "start": 350770, "crunched": 0, "end": 351936, "filename": "/src/objects/Tombstone.lua"}, {"audio": 0, "start": 351936, "crunched": 0, "end": 353146, "filename": "/src/objects/Nest.lua"}, {"audio": 0, "start": 353146, "crunched": 0, "end": 358012, "filename": "/src/objects/Pet.lua"}, {"audio": 0, "start": 358012, "crunched": 0, "end": 359532, "filename": "/src/objects/Fireball.lua"}, {"audio": 0, "start": 359532, "crunched": 0, "end": 360646, "filename": "/src/objects/Egg.lua"}, {"audio": 0, "start": 360646, "crunched": 0, "end": 362276, "filename": "/src/objects/PetAmanita.lua"}, {"audio": 0, "start": 362276, "crunched": 0, "end": 363661, "filename": "/src/objects/PetDragon.lua"}, {"audio": 0, "start": 363661, "crunched": 0, "end": 365191, "filename": "/src/objects/AppleCrate.lua"}, {"audio": 0, "start": 365191, "crunched": 0, "end": 366072, "filename": "/src/objects/PetFerro.lua"}, {"audio": 0, "start": 366072, "crunched": 0, "end": 366987, "filename": "/src/states/Title.lua"}, {"audio": 0, "start": 366987, "crunched": 0, "end": 376290, "filename": "/src/states/Game.lua"}, {"audio": 0, "start": 376290, "crunched": 0, "end": 378063, "filename": "/src/states/Results.lua"}, {"audio": 0, "start": 378063, "crunched": 0, "end": 379652, "filename": "/src/states/Instructions.lua"}], "remote_package_size": 379652, "package_uuid": "bff738f2-7aaf-48a0-9bf2-44cfce830295"});

})();
