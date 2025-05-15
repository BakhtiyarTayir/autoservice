import 'package:flutter/material.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';

class PartnerListItem extends StatelessWidget {
  final Partner partner;

  const PartnerListItem({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: partner.logo != null 
          ? Image.network(
              'https://api.afix.uz/${partner.logo}',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront_outlined),
            )
          : const Icon(Icons.storefront_outlined),
      title: Text(partner.name),
      subtitle: Text(partner.address),
      onTap: () {
        // TODO: Навигация на экран деталей партнера
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Переход к деталям партнера: ${partner.name} (TODO)')),
        );
      },
    );
  }
}