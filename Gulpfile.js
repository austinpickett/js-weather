const
	gulp = require('gulp'),
	gutil = require('gulp-util'),
	notify = require('gulp-notify'),

	source = require('vinyl-source-stream'),
	buffer = require('vinyl-buffer'),

	sass = require('gulp-sass'),
	cssmin = require('gulp-cssmin'),
	sourcemaps = require('gulp-sourcemaps'),
	uglify = require('gulp-uglify'),
	fileinclude = require('gulp-file-include'),

	browserify = require('browserify'),
	watchify = require('watchify'),
	babel = require('babelify'),
	livereload = require('gulp-server-livereload')

// --------------------------------------------------

gulp.task('sass', () => {
	gulp.src('src/css/main.sass')
	.pipe(sass().on('error', sass.logError))
	.pipe(cssmin())
	.pipe(gulp.dest('dist/css'))
})

gulp.task('html', () => {
	gulp.src('src/*.html')
	.pipe(fileinclude({
		prefix: '@@',
		basepath: '@file'
	}).on('error', gutil.log))
	.pipe(gulp.dest('dist'))
})

gulp.task('browserify', (watch) => {
	const bundler = watchify(browserify('src/js/main.js'), {
		debug: true
	}).transform(babel)

	const rebundle = () => {
		bundler.bundle()
		.on('error', (err) => {
			console.error(err)
		})
		.pipe(source('main.js'))
		.pipe(buffer())
		.pipe(sourcemaps.init({
			loadMaps: true
		}))
		.pipe(gulp.dest('dist/js'))
	}

	bundler.on('update', () => {
		gutil.log('Rebundling')
		rebundle()
	})

	rebundle()
})

gulp.task('server', () => {
	gulp.src('dist')
	.pipe(livereload({
		open: true,
		fallback: 'index.html',
		livereload: true,
		directoryListing: false,
	}))
})

// --------------------------------------------------

gulp.task('default', () => {
	gulp.run('server')
	gulp.run('browserify')

	gulp.watch(['src/*.html'], ['html'])
	gulp.watch(['src/css/**/*.sass'], ['sass'])
})