glados.useNameSpace 'glados.models.paginatedCollections',

  PaginatedCollectionBase: Backbone.Collection.extend

    initialize: ->

      if @islinkToAllActivitiesEnabled()
        @on glados.Events.Collections.SELECTION_UPDATED, @resetLinkToAllActivitiesCache, @

    islinkToAllActivitiesEnabled: -> @getMeta('enable_activities_link_for_selected_entities') == true

    # ------------------------------------------------------------------------------------------------------------------
    # Link to all activities
    # ------------------------------------------------------------------------------------------------------------------
    ALL_ACTIVITIES_LINK_CACHE_PROP_NAME: 'all_activities_link_cache'

    resetLinkToAllActivitiesCache: -> @setMeta(@ALL_ACTIVITIES_LINK_CACHE_PROP_NAME, undefined)
    # because of the paginated nature of the collections, it could happen that in order to get
    # all the selected ids, it has to download all the results, this is why it returns a promise.
    getLinkToAllActivitiesPromise: ->

      cache = @getMeta(@ALL_ACTIVITIES_LINK_CACHE_PROP_NAME)
      if cache?
        return jQuery.Deferred().resolve(cache)

      linkPromise = jQuery.Deferred()

      selectedIDsPromise = @getSelectedItemsIDsPromise()
      thisCollection = @
      selectedIDsPromise.then (selectedIDs) ->

        link = thisCollection.getLinkToAllActivities(selectedIDs)
        thisCollection.setMeta(thisCollection.ALL_ACTIVITIES_LINK_CACHE_PROP_NAME, link)
        linkPromise.resolve(link)

      return linkPromise

    getLinkToAllActivities: (itemsList) ->
      entityName = @getMeta('model').prototype.entityName
      filter = @ENTITY_NAME_TO_FILTER_GENERATOR[entityName]
        ids: itemsList

      return Activity.getActivitiesListURL(filter)

    ENTITY_NAME_TO_FILTER_GENERATOR:
      "#{Compound.prototype.entityName}":\
      Handlebars.compile('molecule_chembl_id:({{#each ids}}"{{this}}"{{#unless @last}} OR {{/unless}}{{/each}})')

