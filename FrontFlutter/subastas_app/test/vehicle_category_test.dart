import 'package:flutter_test/flutter_test.dart';
import 'package:subastas_app/features/auctions/domain/auction.dart';

void main() {
  Auction createAuction({
    required String title,
    String? description,
  }) {
    return Auction(
      id: 'test-1',
      title: title,
      description: description,
      images: const [],
      startingPrice: 1000,
      currentPrice: 1000,
      minIncrement: 50,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      status: 'active',
    );
  }

  group('VehicleCategory Classification', () {
    test('Identifica Pick-ups & 4x4 correctamente', () {
      final f150 = createAuction(
        title: 'Ford F-150 Lariat 2022',
        description: 'Pick-up cabina doble 4x4',
      );
      final silverado = createAuction(
        title: 'Chevrolet Silverado 1500',
        description: 'Camioneta de trabajo',
      );
      final tacoma = createAuction(
        title: 'Toyota Tacoma TRD Pro',
        description: 'Todo terreno 4WD',
      );

      expect(f150.vehicleCategory, VehicleCategory.pickup);
      expect(silverado.vehicleCategory, VehicleCategory.pickup);
      expect(tacoma.vehicleCategory, VehicleCategory.pickup);
      expect(VehicleCategory.pickup.matches(f150), isTrue);
      expect(VehicleCategory.pickup.matches(silverado), isTrue);
      expect(VehicleCategory.pickup.matches(tacoma), isTrue);
      expect(VehicleCategory.sports.matches(f150), isFalse);
    });

    test('Identifica Deportivos & Muscle correctamente', () {
      final mustang = createAuction(
        title: 'Ford Mustang GT 2023',
        description: 'Motor V8 5.0L Coupé Deportivo',
      );
      final camaro = createAuction(
        title: 'Chevrolet Camaro SS',
        description: 'Muscle car potente',
      );
      final porsche = createAuction(
        title: 'Porsche 911 Carrera',
        description: 'Coupé deportivo alemán',
      );

      expect(mustang.vehicleCategory, VehicleCategory.sports);
      expect(camaro.vehicleCategory, VehicleCategory.sports);
      expect(porsche.vehicleCategory, VehicleCategory.sports);
      expect(VehicleCategory.sports.matches(mustang), isTrue);
      expect(VehicleCategory.sports.matches(camaro), isTrue);
      expect(VehicleCategory.sports.matches(porsche), isTrue);
      expect(VehicleCategory.sedan.matches(mustang), isFalse);
    });

    test('Identifica SUVs & Eléctricos correctamente', () {
      final tesla = createAuction(
        title: 'Tesla Model Y Long Range 2024',
        description: 'Vehículo 100% Eléctrico EV',
      );
      final rav4 = createAuction(
        title: 'Toyota RAV4 Hybrid',
        description: 'SUV compacta y eficiente',
      );
      final explorer = createAuction(
        title: 'Ford Explorer XLT',
        description: 'SUV familiar espaciosa',
      );

      expect(tesla.vehicleCategory, VehicleCategory.suvElectric);
      expect(rav4.vehicleCategory, VehicleCategory.suvElectric);
      expect(explorer.vehicleCategory, VehicleCategory.suvElectric);
      expect(VehicleCategory.suvElectric.matches(tesla), isTrue);
      expect(VehicleCategory.suvElectric.matches(rav4), isTrue);
      expect(VehicleCategory.suvElectric.matches(explorer), isTrue);
    });

    test('Identifica Sedanes & Familiares correctamente (incluyendo trims Sport y GT-Line)', () {
      final civic = createAuction(
        title: 'Honda Civic LX 2022',
        description: 'Sedán compacto 4 puertas',
      );
      final accordSport = createAuction(
        title: 'Honda Accord Sport 2021',
        description: 'Sedán mediano, 65,000 km. Daño frontal moderado.',
      );
      final forteGT = createAuction(
        title: 'Kia Forte GT-Line 2022',
        description: 'Sedán compacto, 50,000 km. Reclamo de aseguradora.',
      );
      final corolla = createAuction(
        title: 'Toyota Corolla LE 2021',
        description: 'Sedán económico y confiable',
      );
      final jetta = createAuction(
        title: 'Volkswagen Jetta R-Line',
        description: 'Sedán con excelente confort',
      );

      expect(civic.vehicleCategory, VehicleCategory.sedan);
      expect(accordSport.vehicleCategory, VehicleCategory.sedan);
      expect(forteGT.vehicleCategory, VehicleCategory.sedan);
      expect(corolla.vehicleCategory, VehicleCategory.sedan);
      expect(jetta.vehicleCategory, VehicleCategory.sedan);
      expect(VehicleCategory.sedan.matches(accordSport), isTrue);
      expect(VehicleCategory.sedan.matches(forteGT), isTrue);
      expect(VehicleCategory.sports.matches(accordSport), isFalse);
      expect(VehicleCategory.sports.matches(forteGT), isFalse);
    });

    test('VehicleCategory.all coincide con cualquier vehículo', () {
      final sportsCar = createAuction(title: 'Ford Mustang GT');
      final pickup = createAuction(title: 'Toyota Hilux 4x4');
      final suv = createAuction(title: 'Tesla Model Y');

      expect(VehicleCategory.all.matches(sportsCar), isTrue);
      expect(VehicleCategory.all.matches(pickup), isTrue);
      expect(VehicleCategory.all.matches(suv), isTrue);
    });
  });
}
