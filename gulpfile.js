var gulp = require('gulp');
var coffee = require('gulp-coffee');
var header = require('gulp-header');

var banner = [
  '// x.coffee -- JavaScript/CoffeeScript implementation of Knuth\'s Algorithm X',
  '// (c) 2015- Felix Henninger & contributors',
  '// x.coffee is licensed under the MIT license.\n\n'
  ].join('\n');

gulp.task('compile', function() {
  return gulp.src(['src/*.coffee'])
    .pipe(coffee({bare: true}))
    .pipe(header(banner))
    .pipe(gulp.dest('.'));
});

gulp.task('watch', function() {
  gulp.watch('src/*.coffee', ['compile']);
});

gulp.task('default', ['compile', 'watch']);
