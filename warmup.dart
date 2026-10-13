class Bus {
  Bus({required this.route, required this.price});

  final String route;
  final int price;
  final seats = List<String?>.filled(6, null);

  void book(String name, int seat) {
    seats[seat - 1] = name;
  }

  int freeSeats() {
    return seats.where((s) => s == null).length;
  }
}

class Button {
  Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  void tap() {
    print('[$label] was tapped');
    onPressed();
  }
}

void main() {
  // FIXED: Added the required 'price' parameter to fix the error.
  final huye = Bus(route: 'huye', price: 3000);
  final musanze = Bus(price: 2500, route: 'musanze');

  huye.book('Keza', 3);
  print('${huye.route}: ${huye.freeSeats()} free');
  print('${musanze.route}: ${musanze.freeSeats()} free');

  final bookButton = Button(
    label: 'Book seat 1',
    onPressed: () {
      huye.book('Eric', 1);
      print('Eric booked. ${huye.freeSeats()} free on huye');
    },
  );

  // FIXED: Created the cancelButton as requested.
  final cancelButton = Button(
      label: 'Cancel seat 1',
      onPressed: () {
        huye.seats[0] = null; // Empties seat 1
        print('${huye.freeSeats()} free on huye');
      }
  );

  print('Nothing happens until someone taps...');
  bookButton.tap();

  // FIXED: Called cancelButton tap after bookButton.
  cancelButton.tap();
}