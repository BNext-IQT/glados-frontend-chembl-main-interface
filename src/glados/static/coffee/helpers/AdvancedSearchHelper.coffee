glados.useNameSpace 'glados.helpers',
  AdvancedSearchHelper: class AdvancedSearchHelper

    @showAdvancedSearchModal = ->

      console.log('SHOW ADVANCED SEARCH MODAL')

      editorModalID = 'modal-AdvancedSearch'
      $editorModal = $("#BCK-GeneratedModalsContainer ##{editorModalID}")

      if $editorModal.length == 0

        $editorModal = ButtonsHelper.generateModalFromTemplate($trigger=undefined,
          'Handlebars-Common-AdvancedSearchModal',
          startingTop=undefined, endingTop=undefined, customID=editorModalID)

      $editorModal.modal('open')