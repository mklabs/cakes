## cakes

collection of cake files, mainly trying to learn [this cool stuff](https://github.com/jashkenas/coffee-script/wiki/%5BHowTo%5D-Compiling-and-Setting-Up-Build-Tools)

## install

In the root of this repo, run

    npm install

It'll get the dependencies as defined in the `package.json` file.

#### h5bp

Experimental collection of cake tasks, cd to h5bp and run `cake`

    cake docs                 # Generates the source documentation of this cake script
    cake createproject        # a simple create project task
    cake intro                # Kindly inform the developer about the impending magic
    cake clean                # Wipe the previous build
    cake mkdirs               # Create the directory structure
    cake js.main.concat       # Concatenates the JS files in dir.js
    cake js.mylibs.concat     # Concatenates the JS files in dir.js.mylibs
    cake js.scripts.concat    # Concatenating library file with main script file
    cake js.all.minify        # Minifies the scripts.js files in intermediate/js
    cake jshint               # jshint task, run jshint on any non min.js file in dir.js
    cake csslint              # csslint task, run csslint on dir.css and ommit *.min.css one
    cake usemin               # Replaces references to non-minified scripts
    cake manifest             # copying a fresh file.manifest to dir.intermediate
    cake htmlclean            # Run htmlcompressor on the HTML
    cake htmlbuildkit         # Run htmlcompressor on the HTML
    cake htmlcompress         # Run htmlcompressor on the HTML

Primary as learning material, I thought that the h5bp build script could
be a great way to play with coffeescript and cake files. 

For now, the following tasks are functionnal:

* **docs**: Generates the source documentation of the Cakefile, and helper
  module
* **createproject**: git clone or pull master branch of html5-boilerplate
  repo
* **intro, clean, mkdirs**: output the intro message, clean directories and
  make directory structure
* **js tasks**: minification is done using [uglify-js](https://github.com/mishoo/UglifyJS) with standards options
* **jshint**: lint code through [jshint](https://github.com/jshint/node-jshint) with standard options (should
  install jshint: `npm install jshint -g`
* **csslint**: lint css files through [csshint](https://github.com/stubbornella/csslint) with standard options (should
  install jshint: `npm install csshint -g`

The tasks related to html compression are just stumb method (usemin to
htmlcompress)

Also a great way to play with Cakefile and EventEmitter to deal with node asynchronicity


