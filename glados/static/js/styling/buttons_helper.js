// Generated by CoffeeScript 1.4.0
var contract, expand, initCroppedContainers, setContractIcon, setExpandIcon, toggleCroppedContainerWrapper;

expand = function(elem) {
  elem.removeClass("cropped");
  return elem.addClass("expanded");
};

contract = function(elem) {
  elem.removeClass("expanded");
  return elem.addClass("cropped");
};

setExpandIcon = function(elem) {
  $(elem).removeClass('fa-compress');
  return $(elem).addClass('fa-expand');
};

setContractIcon = function(elem) {
  $(elem).addClass('fa-compress');
  return $(elem).removeClass('fa-expand');
};

/* *
  * @param {JQuery} elem element that is going to be toggled
  * @param {JQuery} ellipsis element that contains the ellipsis to be hidden.
  * @return {Function} function that toggles the cropped container
*/


toggleCroppedContainerWrapper = function(elem, ellipsis) {
  var toggleCroppedContainer;
  toggleCroppedContainer = function() {
    if (elem.hasClass("expanded")) {
      contract(elem);
      ellipsis.show();
      return setExpandIcon($(this).find('i'));
    } else {
      expand(elem);
      ellipsis.hide();
      return setContractIcon($(this).find('i'));
    }
  };
  return toggleCroppedContainer;
};

/* *
  * Initializes the cropped container on the current element
  * The element that calls this function must be of the class cropped-container
*/


initCroppedContainers = function() {
  return $('.cropped-container').each(function() {
    var activated, activator, ellipsis, numLetters, toggler;
    activator = $(this).find('a[data-activates]');
    activated = $('#' + activator.attr('data-activates'));
    ellipsis = $(this).find('.cropped-container-ellipsis');
    numLetters = 0;
    activated.children().each(function() {
      return numLetters += $(this).text().trim().length;
    });
    if (numLetters < 100) {
      ellipsis.hide();
      activator.hide();
      return;
    }
    console.log(activated.children().text().length);
    toggler = toggleCroppedContainerWrapper(activated, ellipsis);
    return activator.click(toggler);
  });
};
