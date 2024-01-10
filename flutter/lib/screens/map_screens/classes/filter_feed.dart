class FilterFeed {
  final String userFilter;
  final String timeLineFilter;
  final String orderFilter;

  FilterFeed({required this.userFilter, required this.timeLineFilter, required this.orderFilter});

  static FilterFeed assignFilters({required String userFilter, required String timeLineFilter, required String orderFilter}) {
    return FilterFeed(
        userFilter: userFilter,
        timeLineFilter: timeLineFilter,
        orderFilter: orderFilter
    );
  }
}