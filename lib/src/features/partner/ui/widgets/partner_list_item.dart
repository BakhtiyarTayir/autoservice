import 'package:flutter/material.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';

class PartnerListItem extends StatelessWidget {
  final Partner partner;
  final bool isCompact;

  const PartnerListItem({
    super.key, 
    required this.partner, 
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Если нужен компактный режим для отображения в слайдере, возвращаем ListTile
    if (isCompact) {
      return ListTile(
        leading: Container(
          width: 40 * 1.5, // Чуть шире для логотипа
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Center(
            child: _buildLogo(context, 40),
          ),
        ),
        title: Text(
          partner.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          partner.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _onTapPartner(context),
      );
    }

    // Иначе возвращаем более детальную карточку
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60 * 1.8, // Соответствует ширине logoWidth из _buildLogo
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: _buildLogo(context, 60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partner.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (partner.description != null && partner.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        partner.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Телефон
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(partner.phone, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              
              // Кнопки
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.location_on, size: 16),
                    label: const Text('На карте'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), 
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      final lat = partner.latitude;
                      final lng = partner.longitude;
                      if (lat != null && lng != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Открываем карту: $lat, $lng (TODO)')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Координаты не указаны')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _onTapPartner(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Подробнее'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, double size) {
    // Для широких логотипов увеличиваем ширину, сохраняя квадратную высоту
    final double logoWidth = isCompact ? size : size * 1.8;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: partner.logo != null
          ? Image.network(
              'https://api.afix.uz/${partner.logo}',
              width: logoWidth,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: logoWidth,
                height: size,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
              ),
            )
          : Container(
              width: logoWidth,
              height: size,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
            ),
    );
  }

  void _onTapPartner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Переход к деталям партнера: ${partner.name} (TODO)')),
    );
  }
}