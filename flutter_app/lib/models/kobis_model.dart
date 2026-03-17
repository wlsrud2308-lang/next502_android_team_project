// 영화 상세 정보 모델 클래스 (필요 없는 데이터 싹 제거!)
class DailyBoxOfficeItem {
  final String? rnum;           // 순번
  final String? rank;           // 순위
  final String? rankInten;      // 전일 대비 순위 증감
  final String? rankOldAndNew;  // 신규 진입 여부
  final String? movieCd;        // 영화 코드
  final String? movieNm;        // 영화명 (DB: title 에 들어갈 예정)
  final String? openDt;         // 개봉일 (DB: release_date 에 들어갈 예정)

  DailyBoxOfficeItem({
    this.rnum,
    this.rank,
    this.rankInten,
    this.rankOldAndNew,
    this.movieCd,
    this.movieNm,
    this.openDt,
  });


  factory DailyBoxOfficeItem.fromJson({required Map<String, dynamic> jsonData}) {
    return DailyBoxOfficeItem(
      rnum: jsonData['rnum'],
      rank: jsonData['rank'],
      rankInten: jsonData['rankInten'],
      rankOldAndNew : jsonData['rankOldAndNew'],
      movieCd: jsonData['movieCd'],
      movieNm: jsonData['movieNm'],
      openDt: jsonData['openDt'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'rnum': rnum,
      'rank': rank,
      'rankInten': rankInten,
      'rankOldAndNew': rankOldAndNew,
      'movieCd': movieCd,
      'movieNm': movieNm,
      'openDt': openDt,
    };
  }
}

class BoxOfficeResult {
  final String boxofficeType;
  final String showRange;
  final List<DailyBoxOfficeItem> dailyBoxOfficeList;

  BoxOfficeResult({
    required this.boxofficeType,
    required this.showRange,
    required this.dailyBoxOfficeList
  });

  factory BoxOfficeResult.fromJson({required Map<String, dynamic> jsonData}) {
    var list = jsonData['dailyBoxOfficeList'] as List;
    List<DailyBoxOfficeItem> dailyBoxOfficeItemList = list.map((item) => DailyBoxOfficeItem.fromJson(jsonData: item)).toList();

    return BoxOfficeResult(
        boxofficeType: jsonData['boxofficeType'],
        showRange: jsonData['showRange'],
        dailyBoxOfficeList: dailyBoxOfficeItemList
    );
  }
}

class DailyBoxOfficeResponse {
  final BoxOfficeResult boxOfficeResult;

  DailyBoxOfficeResponse({required this.boxOfficeResult});

  factory DailyBoxOfficeResponse.fromJson({required Map<String, dynamic> jsonData}) {
    return DailyBoxOfficeResponse(
        boxOfficeResult: BoxOfficeResult.fromJson(jsonData: jsonData['boxOfficeResult'])
    );
  }
}