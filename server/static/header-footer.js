window.onload = () => {
  $.get('header.html', function (data) {
    $('#header').html(data)
  })
}
