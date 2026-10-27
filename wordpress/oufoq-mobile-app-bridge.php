<?php
/**
 * Plugin Name: Oufoq Mobile App Bridge
 * Description: نقطة اتصال خفيفة لتطبيق منصة أفق (إعدادات الإعلانات عن بُعد وتحسين الصور)
 * Version: 1.0.0
 * Author: Oufoq Platform
 *
 * ثبّت الملف كإضافة مستقلة أو ضع كوده في functions.php الخاص بالقالب الفرعي.
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', function () {
    // 1) نقطة نهاية لإعدادات التطبيق والتحكم بإعلانات AdMob عن بُعد
    register_rest_route('oufoq/v1', '/config', [
        'methods'             => 'GET',
        'permission_callback' => '__return_true',
        'callback'            => function () {
            return [
                'min_supported_version' => '1.0.0',
                'breaking_category_id'  => 12, // عدّل الرقم حسب قسم العاجل في موقعك
                'ads' => [
                    'enabled'                        => true,
                    'banner_enabled'                 => true,
                    'native_enabled'                 => true,
                    'native_interval'                => 5,
                    'interstitial_enabled'           => true,
                    'interstitial_article_threshold' => 4,
                    'interstitial_cooldown_minutes'  => 3,
                    'app_open_enabled'               => false,
                ],
                'languages' => [
                    'active' => ['ar'], // أضف 'en' و 'fr' لاحقاً
                ],
            ];
        },
    ]);

    // 2) إرفاق رابط الصورة البارزة مباشرة في استجابة المقال لتسريع التطبيق
    register_rest_field('post', 'oufoq_featured_image', [
        'get_callback' => function ($post_arr) {
            $thumb_id = get_post_thumbnail_id($post_arr['id']);
            if (!$thumb_id) {
                return null;
            }
            return [
                'medium' => wp_get_attachment_image_url($thumb_id, 'medium_large'),
                'full'   => wp_get_attachment_image_url($thumb_id, 'full'),
            ];
        },
    ]);
});
