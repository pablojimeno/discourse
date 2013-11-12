Discourse.DiscourseHeadingComponent = Ember.Component.extend({
  tagName: 'th',

  classNameBindings: ['number:num', 'sortBy', 'iconSortClass:sorting', 'sortBy:sortable'],
  attributeBindings: ['colspan'],

  iconSortClass: function() {
    var sortBy = this.get('sortBy');
    if (sortBy && sortBy === this.get('sortOrder.order')) {
      return this.get('sortOrder.descending') ? 'icon-chevron-down' : 'icon-chevron-up';
    }
  }.property('sortOrder.order', 'sortOrder.descending'),

  click: function() {
    var sortOrder = this.get('sortOrder'),
        sortBy = this.get('sortBy');

    if (sortBy && sortOrder) {
      sortOrder.toggle(sortBy);
    }
  }
});
