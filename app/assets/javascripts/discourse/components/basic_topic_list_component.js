/**
  This view is used for rendering a basic list of topics.

  @class BasicTopicListView
  @extends Discourse.View
  @namespace Discourse
  @module Discourse
**/
Discourse.DiscourseBasicTopicListComponent = Ember.Component.extend({

  init: function() {
    this._super();
    this.set('sortOrder', Discourse.SortOrder.create());
  }

});
