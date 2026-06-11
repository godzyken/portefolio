import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portefolio/resources/resources.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.agile).existsSync(), isTrue);
    expect(File(Images.conseillerServiceClient).existsSync(), isTrue);
    expect(File(Images.continentalHvac).existsSync(), isTrue);
    expect(File(Images.etricksBmx).existsSync(), isTrue);
    expect(File(Images.flutterMascotte).existsSync(), isTrue);
    expect(File(Images.gettyImages).existsSync(), isTrue);
    expect(File(Images.livreurAmazon).existsSync(), isTrue);
    expect(File(Images.mePortrait2).existsSync(), isTrue);
    expect(File(Images.persDoAm).existsSync(), isTrue);
    expect(File(Images.pieceMoto).existsSync(), isTrue);
    expect(File(Images.prestashop).existsSync(), isTrue);
    expect(File(Images.tmeLivreur).existsSync(), isTrue);
    expect(File(Images.transformationDigitale).existsSync(), isTrue);
    expect(File(Images.vignetteClipArticles1).existsSync(), isTrue);
    expect(File(Images.vignetteClipArtiste).existsSync(), isTrue);
  });
}
