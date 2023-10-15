class PriceUtil {
  static int getTotalPrice({required int marketPrice, required int lotPrice, required int loadingPrice, required double ho, required bool floatRound}) {
    if(floatRound) {
      return _getTotalPriceFloat(marketPrice, lotPrice, loadingPrice, ho);
    }
    else {
      return _getTotalPriceInt(marketPrice, lotPrice, loadingPrice, ho);
    }
  }

  static int _getTotalPriceFloat(int marketPrice, int lotPrice, int loadingPrice, double ho) {
    return ((((marketPrice + loadingPrice) / 0.7) + lotPrice) * ho).round();
  }

  static int _getTotalPriceInt(int marketPrice, int lotPrice, int loadingPrice, double ho) {
    int num = ((((marketPrice + loadingPrice) / 0.7) + lotPrice) * ho).toInt();
    int temp = num % 10;
    num = num ~/ 10;

    if(temp >= 5) {
      num += 1;
    }

    return num * 10;
  }
}