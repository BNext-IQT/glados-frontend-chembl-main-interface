// Generated by CoffeeScript 1.4.0
var ButtonsHelper, complementaryinitSideNav, contract, cropTextIfNecessary, expand, hideExpandableMenu, hideExpandableMenuWrapper, initCroppedContainers, initCroppedTextFields, initExpendableMenus, setLessText, setMoreText, showExpandableMenu, toggleCroppedContainerWrapper, toggleExpandableMenuWrapper;

ButtonsHelper = function() {};

/* *
  * @param {JQuery} elem button that triggers the download
  * @param {String} filename Name that you want for the downloaded file
  * @param {tolltip} Tooltip that you want for the button
  * @param {String} data data that is going to be downloaded
*/


ButtonsHelper.initDownloadBtn = function(elem, filename, tooltip, data) {
  elem.attr('download', filename);
  elem.addClass('tooltipped');
  elem.attr('data-tooltip', tooltip);
  return elem.attr('href', 'data:text/html,' + data);
};

/* *
  * Handles the copy event
  * it gets the information from the context, It doesn't use a closure to be faster
*/


ButtonsHelper.handleCopy = function() {
  var tooltip, tooltip_id;
  clipboard.copy($(this).attr('data-copy'));
  tooltip_id = $(this).attr('data-tooltip-id');
  tooltip = $('#' + tooltip_id);
  if ($(window).width() <= MEDIUM_WIDTH) {
    tooltip.hide();
    Materialize.toast('Copied!', 1000);
  } else {
    tooltip.find('span').text('Copied!');
  }
  return console.log('copied!');
};

ButtonsHelper.initCopyButton = function(elem, tooltip, data) {
  var copy_btn;
  copy_btn = elem;
  copy_btn.addClass('tooltipped');
  copy_btn.attr('data-tooltip', tooltip);
  copy_btn.attr('data-copy', data);
  return copy_btn.click(ButtonsHelper.handleCopy);
};

expand = function(elem) {
  elem.removeClass("cropped");
  return elem.addClass("expanded");
};

contract = function(elem) {
  elem.removeClass("expanded");
  return elem.addClass("cropped");
};

setMoreText = function(elem) {
  var icon;
  icon = $(elem).children('i');
  icon.removeClass('fa-caret-up');
  return icon.addClass('fa-caret-down');
};

setLessText = function(elem) {
  var icon;
  icon = $(elem).children('i');
  icon.removeClass('fa-caret-down');
  return icon.addClass('fa-caret-up');
};

/* *
  * @param {JQuery} elem element that is going to be toggled
  * @param {JQuery} buttons element that contains the buttons that activate this..
  * @return {Function} function that toggles the cropped container
*/


toggleCroppedContainerWrapper = function(elem, buttons) {
  var toggleCroppedContainer;
  toggleCroppedContainer = function() {
    if (elem.hasClass("expanded")) {
      contract(elem);
      setMoreText($(this));
      return buttons.removeClass('cropped-container-btns-exp');
    } else {
      expand(elem);
      setLessText($(this));
      return buttons.addClass('cropped-container-btns-exp');
    }
  };
  return toggleCroppedContainer;
};

/* *
  * Initializes the cropped container on the elements of the class 'cropped-container'
*/


initCroppedContainers = function() {
  var f;
  f = function() {
    return $('.cropped-container').each(function() {
      var activated, activator, buttons, heightLimit, overflow, toggler;
      activator = $(this).find('a[data-activates]');
      activated = $('#' + activator.attr('data-activates'));
      buttons = $(this).find('.cropped-container-btns');
      overflow = false;
      heightLimit = activated.offset().top + activated.height();
      activated.children().each(function() {
        var childHeightLimit;
        childHeightLimit = $(this).offset().top + $(this).height();
        if (childHeightLimit > heightLimit) {
          overflow = true;
          return false;
        }
      });
      if (overflow) {
        toggler = toggleCroppedContainerWrapper(activated, buttons);
        activator.click(toggler);
        return activator.show();
      }
    });
  };
  return _.debounce(f, 100)();
};

showExpandableMenu = function(activator, elem) {
  activator.html('<i class="material-icons">remove</i>');
  return elem.slideDown(300);
};

hideExpandableMenu = function(activator, elem) {
  activator.html('<i class="material-icons">add</i>');
  return elem.slideUp(300);
};

hideExpandableMenuWrapper = function(activator, elem_id_list) {
  var toggleExpandableMenu;
  toggleExpandableMenu = function() {
    return $.each(elem_id_list, function(index, elem_id) {
      var elem;
      elem = $('#' + elem_id);
      return hideExpandableMenu(activator, elem);
    });
  };
  return toggleExpandableMenu;
};

/* *
* @param {JQuery} activator element that activates toggles the expandable menu
  * @param {Array} elem_id_list list of menu elements that are going to be shown
  * @return {Function} function that toggles the expandable menus
*/


toggleExpandableMenuWrapper = function(activator, elem_id_list) {
  var toggleExpandableMenu;
  toggleExpandableMenu = function() {
    return $.each(elem_id_list, function(index, elem_id) {
      var elem;
      elem = $('#' + elem_id);
      if (elem.css('display') === 'none') {
        return showExpandableMenu(activator, elem);
      } else {
        return hideExpandableMenu(activator, elem);
      }
    });
  };
  return toggleExpandableMenu;
};

/* *
  *  Initializes the cropped container on the elements of the class 'expandable-menu'
*/


initExpendableMenus = function() {
  return $('.expandable-menu').each(function() {
    var activators, currentDiv;
    currentDiv = $(this);
    activators = $(this).find('a[data-activates]');
    return activators.each(function() {
      var activated_list, activated_list_selectors, activator, hider, toggler;
      activator = $(this);
      activated_list = activator.attr('data-activates').split(',');
      toggler = toggleExpandableMenuWrapper(activator, activated_list);
      activator.click(toggler);
      hider = hideExpandableMenuWrapper(activator, activated_list);
      activated_list_selectors = '';
      $.each(activated_list, function(index, elem_id) {
        return activated_list_selectors += '#' + elem_id + ', ';
      });
      $('body').click(function(e) {
        if (!$.contains(currentDiv[0], e.target)) {
          return hider();
        }
      });
      return activator.click(function(event) {
        return event.stopPropagation();
      });
    });
  });
};

/* *
  *  Initializes the cropped container on the elements of the class 'cropped-text-field'
  * It is based on an input field to show the information
*/


initCroppedTextFields = function() {
  return $('.cropped-text-field').each(function() {
    var currentDiv, input_field;
    currentDiv = $(this);
    input_field = $(this).find('input');
    input_field.click(function() {
      input_field.val(currentDiv.attr('data-original-value'));
      return input_field.select();
    });
    $(this).attr('data-original-value', input_field.attr('value'));
    input_field.focusout(function() {
      return cropTextIfNecessary(currentDiv);
    });
    $(window).resize(function() {
      if (currentDiv.is(':visible')) {
        return cropTextIfNecessary(currentDiv);
      }
    });
    return cropTextIfNecessary(currentDiv);
  });
};

/* *
  * Decides if the input contained in the div is overlapping and the ellipsis must be shown.
  * if it is overlapping, shows the ellipsis and crops the text, if not, it doesn't show the ellipsis
  * and shows all the text in the input
  * @param {JQuery} input_div element that contains the ellipsis and the input
*/


cropTextIfNecessary = function(input_div) {
  var charLength, input_field, numVisibleChars, originalInputValue, partSize, shownValue;
  input_field = input_div.find('input')[0];
  originalInputValue = input_div.attr('data-original-value');
  if (originalInputValue === void 0) {
    return;
  }
  input_field.value = originalInputValue;
  charLength = input_field.scrollWidth / originalInputValue.length;
  numVisibleChars = Math.round(input_field.clientWidth / charLength);
  if (input_field.scrollWidth > input_field.clientWidth) {
    partSize = (numVisibleChars / 2) - 2;
    shownValue = originalInputValue.substring(0, partSize) + ' ... ' + originalInputValue.substring(originalInputValue.length - partSize + 2, originalInputValue.length);
    return input_field.value = shownValue;
  } else {
    return input_field.value = originalInputValue;
  }
};

/* *
  *  This is necessary to fix the bug of the side nav not appearing correctly.
*/


complementaryinitSideNav = function() {
  return $('.button-collapse').each(function() {
    var currentBtn;
    currentBtn = $(this);
    return currentBtn.click(function() {
      var activated;
      activated = $('#' + $(this).attr('data-activates'));
      return activated.show();
    });
  });
};
