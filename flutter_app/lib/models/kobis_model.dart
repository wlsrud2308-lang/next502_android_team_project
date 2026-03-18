// 영화 상세 정보 모델 클래스 (필요 없는 데이터 싹 제거!)
class DailyBoxOfficeItem {
  final String? rnum;
  final String? rank;
  final String? rankInten;
  final String? rankOldAndNew;
  final String? movieCd;
  final String? movieNm;
  final String? openDt;
  final String? salesAmt;
  final String? salesShare;
  final String? salesInten;
  final String? salesChange;
  final String? salesAcc;
  final String? audiCnt;
  final String? audiInten;
  final String? audiChange;
  final String? audiAcc;
  final String? scrnCnt;
  final String? showCnt;

  DailyBoxOfficeItem({
    required this.rnum,
    required this.rank,
    required this.rankInten,
    required this.rankOldAndNew,
    required this.movieCd,
    required this.movieNm,
    required this.openDt,
    required this.salesAmt,
    required this.salesShare,
    required this.salesInten,
    required this.salesChange,
    required this.salesAcc,
    required this.audiCnt,
    required this.audiInten,
    required this.audiChange,
    required this.audiAcc,
    required this.scrnCnt,
    required this.showCnt
  });


  factory DailyBoxOfficeItem.fromJson({required Map<String, dynamic> jsonData}) {
    return DailyBoxOfficeItem(
        rnum: jsonData['rnum'],
        rank: jsonData['rank'],
        rankInten: jsonData['rankInten'],
        rankOldAndNew: jsonData['rankOldAndNew'],
        movieCd: jsonData['movieCd'],
        movieNm: jsonData['movieNm'],
        openDt: jsonData['openDt'],
        salesAmt: jsonData['salesAmt'],
        salesShare: jsonData['salesShare'],
        salesInten: jsonData['salesInten'],
        salesChange: jsonData['salesChange'],
        salesAcc: jsonData['salesAcc'],
        audiCnt: jsonData['audiCnt'],
        audiInten: jsonData['audiInten'],
        audiChange: jsonData['audiChange'],
        audiAcc: jsonData['audiAcc'],
        scrnCnt: jsonData['scrnCnt'],
        showCnt: jsonData['showCnt']
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
      'salesAmt': salesAmt,
      'salesShare': salesShare,
      'salesInten': salesInten,
      'salesChange': salesChange,
      'salesAcc': salesAcc,
      'audiCnt': audiCnt,
      'audiInten': audiInten,
      'audiChange': audiChange,
      'audiAcc': audiAcc,
      'scrnCnt': scrnCnt,
      'showCnt': showCnt,
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