import 'package:flutter_test/flutter_test.dart';
import 'package:oufoq_platform/features/article/data/models/article_model.dart';

void main() {
  group('ArticleModel.fromJson', () {
    test('الحالة 1: مقال كامل مع _embedded والصورة البارزة والقسم والمؤلف', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 101,
        'slug': 'full-post',
        'link': 'https://example.com/full-post',
        'date': '2026-10-27T08:30:00',
        'modified': '2026-10-27T09:00:00',
        'title': <String, dynamic>{'rendered': '<h1>عنوان &laquo;رئيسي&raquo;</h1>'},
        'excerpt': <String, dynamic>{'rendered': '<p>مقتطف &amp; تفاصيل</p>'},
        'content': <String, dynamic>{
          'rendered': '<p>هذا نص المقال الكامل لاختبار وقت القراءة.</p>'
        },
        'categories': <int>[2, 5],
        'featured_media': 77,
        '_embedded': <String, dynamic>{
          'wp:featuredmedia': <dynamic>[
            <String, dynamic>{
              'source_url': 'https://example.com/full.jpg',
              'media_details': <String, dynamic>{
                'sizes': <String, dynamic>{
                  'medium_large': <String, dynamic>{
                    'source_url': 'https://example.com/medium.jpg'
                  },
                  'large': <String, dynamic>{
                    'source_url': 'https://example.com/large.jpg'
                  },
                }
              }
            }
          ],
          'wp:term': <dynamic>[
            <dynamic>[
              <String, dynamic>{
                'taxonomy': 'category',
                'name': 'سياسة &amp; اقتصاد'
              }
            ]
          ],
          'author': <dynamic>[
            <String, dynamic>{'name': 'هيئة التحرير'}
          ],
        },
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.id, 101);
      expect(model.title, 'عنوان «رئيسي»');
      expect(model.excerpt, 'مقتطف & تفاصيل');
      expect(model.categoryIds, <int>[2, 5]);
      expect(model.featuredImageThumbUrl, 'https://example.com/medium.jpg');
      expect(model.featuredImageFullUrl, 'https://example.com/full.jpg');
      expect(model.primaryCategoryName, 'سياسة & اقتصاد');
      expect(model.authorName, 'هيئة التحرير');
      expect(model.publishedAt, DateTime(2026, 10, 27, 8, 30));
      expect(model.readingTimeMinutes, greaterThanOrEqualTo(1));
      expect(model.hasFeaturedImage, isTrue);
    });

    test('الحالة 2: مقال بدون صورة بارزة لا يرمي استثناء', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 202,
        'slug': 'no-image',
        'link': 'https://example.com/no-image',
        'date': '2026-10-26T10:00:00',
        'title': <String, dynamic>{'rendered': 'مقال بدون صورة'},
        'excerpt': <String, dynamic>{'rendered': ''},
        'content': <String, dynamic>{'rendered': '<p>محتوى</p>'},
        'categories': <int>[],
        'featured_media': 0,
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.id, 202);
      expect(model.title, 'مقال بدون صورة');
      expect(model.featuredImageThumbUrl, isNull);
      expect(model.featuredImageFullUrl, isNull);
      expect(model.hasFeaturedImage, isFalse);
      expect(model.primaryCategoryName, isNull);
      expect(model.categoryIds, isEmpty);
    });

    test('الحالة 3: كيانات HTML عربية وإنجليزية معقدة وحالة صورة محمية', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 303,
        'slug': 'entities',
        'link': 'https://example.com/entities',
        'date': '2026-10-25T20:15:00',
        'title': <String, dynamic>{
          'rendered': '&#8220;Arabic &#8211; English&#8221; &hellip; &#x2014; end'
        },
        'excerpt': <String, dynamic>{
          'rendered': 'Quotes &#8216;single&#8217; &quot;double&quot; &nbsp; ok'
        },
        'content': <String, dynamic>{
          'rendered': '<p>Some <strong>bold</strong> content</p>'
        },
        'categories': <int>[1],
        '_embedded': <String, dynamic>{
          // ووردبريس قد يعيد كائن خطأ بدل الصورة المحمية/المحذوفة.
          'wp:featuredmedia': <dynamic>[
            <String, dynamic>{
              'code': 'rest_forbidden',
              'message': 'Sorry, you are not allowed to do that.'
            }
          ],
          'wp:term': <dynamic>[
            <dynamic>[
              <String, dynamic>{'taxonomy': 'category', 'name': 'عاجل'}
            ]
          ],
        },
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.title, '“Arabic – English” … — end');
      expect(model.excerpt, 'Quotes ‘single’ "double" ok');
      expect(model.featuredImageThumbUrl, isNull);
      expect(model.primaryCategoryName, 'عاجل');
      expect(model.htmlContent.contains('<script>'), isFalse);
    });

    test('يفضّل date_gmt/modified_gmt ويعاملهما كتوقيت UTC', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 505,
        'slug': 'gmt-dates',
        'link': 'https://example.com/gmt-dates',
        'date': '2026-10-27T11:30:00',
        'date_gmt': '2026-10-27T08:30:00',
        'modified': '2026-10-27T12:00:00',
        'modified_gmt': '2026-10-27T09:00:00',
        'title': <String, dynamic>{'rendered': 'تواريخ'},
        'excerpt': <String, dynamic>{'rendered': ''},
        'content': <String, dynamic>{'rendered': '<p>نص</p>'},
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.publishedAt, DateTime.utc(2026, 10, 27, 8, 30));
      expect(model.publishedAt?.isUtc, isTrue);
      expect(model.modifiedAt, DateTime.utc(2026, 10, 27, 9));
    });

    test('يعود إلى date/modified عند غياب حقول GMT', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 606,
        'slug': 'local-dates',
        'link': 'https://example.com/local-dates',
        'date': '2026-10-27T11:30:00',
        'modified': '2026-10-27T12:00:00',
        'title': <String, dynamic>{'rendered': 'تواريخ محلية'},
        'excerpt': <String, dynamic>{'rendered': ''},
        'content': <String, dynamic>{'rendered': '<p>نص</p>'},
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.publishedAt, DateTime(2026, 10, 27, 11, 30));
      expect(model.modifiedAt, DateTime(2026, 10, 27, 12));
    });

    test('يتجاهل روابط الصورة المساوية لـ "false" أو الفارغة', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 707,
        'slug': 'false-image',
        'link': 'https://example.com/false-image',
        'title': <String, dynamic>{'rendered': 'صورة ملغاة'},
        'excerpt': <String, dynamic>{'rendered': ''},
        'content': <String, dynamic>{'rendered': '<p>نص</p>'},
        // جسر ووردبريس قد يعيد false بدل رابط الصورة.
        'oufoq_featured_image': <String, dynamic>{
          'medium': 'false',
          'full': '   ',
        },
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.featuredImageThumbUrl, isNull);
      expect(model.featuredImageFullUrl, isNull);
      expect(model.hasFeaturedImage, isFalse);
    });

    test('يتحمل media_details بقيمة null دون رمي استثناء', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 808,
        'slug': 'null-media-details',
        'link': 'https://example.com/null-media-details',
        'title': <String, dynamic>{'rendered': 'بدون تفاصيل'},
        'excerpt': <String, dynamic>{'rendered': ''},
        'content': <String, dynamic>{'rendered': '<p>نص</p>'},
        '_embedded': <String, dynamic>{
          'wp:featuredmedia': <dynamic>[
            <String, dynamic>{
              'source_url': 'https://example.com/direct.jpg',
              'media_details': null,
            }
          ],
        },
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.featuredImageThumbUrl, 'https://example.com/direct.jpg');
      expect(model.featuredImageFullUrl, 'https://example.com/direct.jpg');
    });

    test('يتحمل حقولاً ناقصة وأنواعاً غير متوقعة دون رمي استثناء', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '404',
        'categories': 'not-a-list',
        'title': 'plain string instead of object',
        '_embedded': <String, dynamic>{
          'wp:featuredmedia': <dynamic>[true],
        },
      };

      final ArticleModel model = ArticleModel.fromJson(json);

      expect(model.id, 404);
      expect(model.title, '');
      expect(model.categoryIds, isEmpty);
      expect(model.featuredImageThumbUrl, isNull);
    });
  });
}
