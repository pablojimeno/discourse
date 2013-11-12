module("Discourse.DiscourseBasicTopicListComponent");

test('defaults', function() {
  var component = Discourse.DiscourseBasicTopicListComponent.create();

  present(component.get('sortOrder'), 'it has a sort order');
});