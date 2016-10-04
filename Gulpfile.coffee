source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

gulp = require 'gulp'
gulpif = require 'gulp-if'
sass = require 'gulp-sass'
gutil = require 'gulp-util'
notify = require 'gulp-notify'
uglify = require 'gulp-uglify'
cssmin = require 'gulp-cssmin'
useref = require 'gulp-useref'
imagemin = require 'gulp-imagemin'

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
			.pipe uglify()
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
		.pipe gulp.dest('dist/css')

gulp.task 'html', ->
	gulp.src('src/index.html')
		.pipe useref()
		.pipe gulpif('*.js', uglify())
		.pipe gulpif('*.css', cssmin())
		.pipe gulp.dest('dist')

gulp.task 'js', -> buildScript false

gulp.task 'images', ->
	gulp.src('src/img/*.{jpg,png}')
		.pipe imagemin({
			progressive: true
		})
		.pipe gulp.dest('dist/img')

gulp.task 'server', ->
	gulp.src('dist')
		.pipe livereload({
			livereload: true
			directoryListing: false
			open: true
			fallback: 'index.html'
		})

gulp.task 'default', ['html', 'server'], ->
	buildScript true
	gulp.watch ['src/index.html'], ['html']
	gulp.watch ['src/css/**/*.sass'], ['sass']
	gulp.watch ['src/img/*'], ['images']

# -----------------------------------------------

gulp.task 'prebuild-js', ->
	gulp.src(['dist/js/*.js'])
		.pipe uglify()
		.pipe gulp.dest('dist/js')

gulp.task 'prebuild-css', ->
	gulp.src(['dist/css/*.css'])
		.pipe cssmin()
		.pipe gulp.dest('dist/css')

gulp.task 'prebuild', ['html', 'prebuild-js', 'prebuild-css']