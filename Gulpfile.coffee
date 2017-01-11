gulp = require 'gulp'
gutil = require 'gulp-util'
notify = require 'gulp-notify'

source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

sass = require 'gulp-sass'
cssmin = require 'gulp-cssmin'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'

browserify = require 'browserify'
babelify = require 'babelify'
watchify = require 'watchify'
livereload = require 'gulp-server-livereload'

# -----------------------------------------------

handleErrors = ->
	args = Array.prototype.slice.call arguments

	notify.onError({
		title: 'Compile Error'
		message: '<%= error.message %>'
	}).apply this, args

	this.emit 'end'

buildScript = (watch) ->
	props = {
		entries: ['src/js/main.js']
		debug: false
		transform: [babelify.configure({
			presets: ['es2015', 'react']
		})]
	}

	bundler = browserify props
	bundler = watchify bundler if watch

	rebundle = ->
		stream = bundler.bundle()

		stream
			.on 'error', handleErrors
			.pipe source('main.js')
			.pipe buffer()
			.pipe sourcemaps.init(loadMaps: true)
			.pipe uglify().on('error', gutil.log)
			.pipe gulp.dest('dist/js')
			.pipe notify({title:'JS rebuilt'})

	bundler.on 'update', ->
		rebundle()
		gutil.log 'Rebundle...'

	rebundle()

# -----------------------------------------------

gulp.task 'sass', ->
	gulp.src 'src/css/main.sass'
		.pipe sass().on('error', sass.logError)
		.pipe cssmin()
		.pipe gulp.dest('dist/css')

gulp.task 'js', -> buildScript false
gulp.task 'html', -> gulp.src('src/*.html').pipe gulp.dest('dist')
gulp.task 'images', -> gulp.src('src/img/*.{jpg,png}').pipe gulp.dest('dist/img')

gulp.task 'server', ->
	gulp.src('dist')
		.pipe livereload({
			livereload: true
			directoryListing: false
			open: true
			fallback: 'index.html'
		})

gulp.task 'default', ['html', 'images', 'server', 'js', 'sass'], ->
	buildScript true

	gulp.watch ['src/*.html'], ['html']
	gulp.watch ['src/css/**/*.sass'], ['sass']
	gulp.watch ['src/img/*'], ['images']