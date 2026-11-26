import 'package:flutter/material.dart';

class WasteType {
  final String key;
  final String label;
  final String bin;
  final Color binColor;
  final IconData icon;
  final List<String> steps;
  final String tip;

  const WasteType({
    required this.key,
    required this.label,
    required this.bin,
    required this.binColor,
    required this.icon,
    required this.steps,
    required this.tip,
  });
}

const wasteTypes = <WasteType>[
  WasteType(
    key: 'Plastic',
    label: 'Plastic',
    bin: 'Yellow bin',
    binColor: Color(0xFFE6B800),
    icon: Icons.local_drink_outlined,
    steps: [
      'Empty and rinse the plastic item.',
      'Remove labels and caps if easy.',
      'Squeeze bottles flat to save space.',
      'Place it in the yellow recycling bin.',
    ],
    tip: 'Soft plastic bags are not curbside recyclable — take them to a supermarket drop-off point.',
  ),
  WasteType(
    key: 'Paper',
    label: 'Paper',
    bin: 'Blue bin',
    binColor: Color(0xFF2F6FD6),
    icon: Icons.description_outlined,
    steps: [
      'Make sure the paper is dry and clean.',
      'Remove sticky tape, staples and plastic windows.',
      'Flatten boxes and cartons.',
      'Place it in the blue paper bin.',
    ],
    tip: 'Greasy pizza boxes cannot be recycled — tear off and recycle the clean parts only.',
  ),
  WasteType(
    key: 'Glass',
    label: 'Glass',
    bin: 'Green bin',
    binColor: Color(0xFF2E7D32),
    icon: Icons.wine_bar_outlined,
    steps: [
      'Rinse the bottle or jar.',
      'Remove metal lids (recycle them with metal).',
      'Do not mix glass with other recycling.',
      'Place it gently in the green glass bin.',
    ],
    tip: 'Broken glass is dangerous — wrap it and take it to a recycling center, not the home bin.',
  ),
  WasteType(
    key: 'Metal',
    label: 'Metal',
    bin: 'Grey bin',
    binColor: Color(0xFF757575),
    icon: Icons.build_outlined,
    steps: [
      'Empty and rinse cans and tins.',
      'Squeeze cans flat.',
      'Keep small pieces together in a larger can.',
      'Place it in the grey metal bin.',
    ],
    tip: 'Metal is one of the most valuable recycling materials — it can be recycled forever.',
  ),
  WasteType(
    key: 'Food',
    label: 'Food',
    bin: 'Compost bin',
    binColor: Color(0xFF795548),
    icon: Icons.restaurant_outlined,
    steps: [
      'Scrape food scraps into the compost bin.',
      'Keep meat and dairy out of home compost.',
      'Add dry leaves or paper to balance it.',
      'Take garden and food waste to a compost site.',
    ],
    tip: 'Food waste in landfill produces methane — composting turns it into plant food.',
  ),
  WasteType(
    key: 'E-waste',
    label: 'E-waste',
    bin: 'Special drop-off',
    binColor: Color(0xFF5C6BC0),
    icon: Icons.devices_other_outlined,
    steps: [
      'Back up and wipe personal data from devices.',
      'Remove batteries if possible.',
      'Do not put electronics in any normal bin.',
      'Take it to an e-waste recycling center.',
    ],
    tip: 'Old phones contain gold and copper — one phone in landfill leaks lead into the soil.',
  ),
  WasteType(
    key: 'Batteries',
    label: 'Batteries',
    bin: 'Hazardous drop-off',
    binColor: Color(0xFFB71C1C),
    icon: Icons.battery_charging_full_outlined,
    steps: [
      'Tape over the terminals of each battery.',
      'Keep battery types separate.',
      'Never put batteries in household bins.',
      'Drop them at a battery collection point.',
    ],
    tip: 'A single button battery can seriously harm a child — always keep them out of reach.',
  ),
  WasteType(
    key: 'Clothes',
    label: 'Clothes',
    bin: 'Textile donation',
    binColor: Color(0xFFEC407A),
    icon: Icons.checkroom_outlined,
    steps: [
      'Wash and dry the items.',
      'Bundle anything still wearable together.',
      'Drop at a charity or textile collection box.',
      'Unwearable cloth goes to a textile recycling bin.',
    ],
    tip: 'Donate good clothes — only 1% of clothing is recycled into new fabric.',
  ),
];
