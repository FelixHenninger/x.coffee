var gulp = require('gulp');
var coffee = require('gulp-coffee');

gulp.task('compile', function() {
  return gulp.src(['src/*.coffee'])
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('.'));
});

gulp.task('watch', function() {
  gulp.watch('src/*.coffee', ['transpile']);
});

gulp.task('default', ['compile', 'watch']);
