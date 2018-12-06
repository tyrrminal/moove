$(document).ready( function () {
  $('table.cardio').DataTable();

  $('.year-disclose').click(function() {
    let y = $(this).attr('data-year');
    $("tr[data-year='"+y+"']:not(.year)").slideUp('slow', function() {
      $('tr.year[data-year="'+y+'"]>td>span.disclosure-closed').css({'visibility': 'visible'});
    });
  });

  $('.year').click(function() {
    let y = $(this).attr('data-year');
    $("tr[data-year='"+y+"']:not(.qtrhidden").slideDown('fast', function() {
      $('tr.year[data-year="'+y+'"]>td>span.disclosure-closed').css({'visibility': 'hidden'});
    });
  });

  $('.quarter-disclose').click(function() {
    let q = $(this).attr('data-quarter');
    let els = $("tr[data-quarter='"+q+"']:not(.quarter)");
    els.slideUp('slow', function() {
      els.addClass('qtrhidden');
      $('.quarter[data-quarter="'+q+'"] .disclosure-closed').css({'visibility': 'visible'});
    });
  });

  $('.quarter').click(function() {
    let q = $(this).attr('data-quarter');
    let els = $("tr[data-quarter='"+q+"']");
    els.slideDown('fast', function() {
      els.removeClass('qtrhidden');
      $('.quarter[data-quarter="'+q+'"] .disclosure-closed').css({'visibility': 'hidden'});
    });
  });

});
