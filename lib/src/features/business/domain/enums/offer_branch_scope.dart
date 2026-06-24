enum OfferBranchScope {
  allBranches,
  selectedBranches,
}

extension OfferBranchScopeX on OfferBranchScope {
  String get labelKey => switch (this) {
        OfferBranchScope.allBranches => 'offers.scope_all_branches',
        OfferBranchScope.selectedBranches => 'offers.scope_selected_branches',
      };
}
