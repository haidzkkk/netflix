
import 'package:spotify/feature/data/api/kk_response/pagination_dto.dart';

class ParamsDTO {
  String? typeSlug;
  List<String>? filterCategory;
  List<String>? filterCountry;
  dynamic filterYear;
  dynamic filterType;
  String? sortField;
  String? sortType;
  PaginationDTO? pagination;

  ParamsDTO(
      {this.typeSlug,
        this.filterCategory,
        this.filterCountry,
        this.filterYear,
        this.filterType,
        this.sortField,
        this.sortType,
        this.pagination});

  ParamsDTO.fromJson(Map<String, dynamic> json) {
    typeSlug = json['type_slug'];
    filterCategory = json['filterCategory'].cast<String>();
    filterCountry = json['filterCountry'].cast<String>();
    filterYear = json['filterYear'];
    filterType = json['filterType'];
    sortField = json['sortField'];
    sortType = json['sortType'];
    pagination = json['pagination'] != null
        ? PaginationDTO.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type_slug'] = typeSlug;
    data['filterCategory'] = filterCategory;
    data['filterCountry'] = filterCountry;
    data['filterYear'] = filterYear;
    data['filterType'] = filterType;
    data['sortField'] = sortField;
    data['sortType'] = sortType;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}