<?php
/**
 * ImgPro CDN Uninstall
 *
 * Removes all plugin data when uninstalled
 *
 * @package ImgPro_CDN
 */

// Exit if accessed directly or not in uninstall context
if (!defined('WP_UNINSTALL_PLUGIN')) {
    exit;
}

/**
 * Fires before ImgPro CDN plugin data is deleted
 *
 * Allows other code to perform cleanup before uninstall
 */
do_action('imgpro_cdn_before_uninstall');

// Delete plugin options
delete_option('imgpro_cdn_settings');
delete_option('imgpro_cdn_version');

// For multisite installations
if (is_multisite()) {
    // Get all sites with pagination for better performance on large networks
    $page = 1;
    $per_page = 100;

    while (true) {
        $sites = get_sites([
            'number' => $per_page,
            'offset' => ($page - 1) * $per_page,
        ]);

        if (empty($sites)) {
            break;
        }

        foreach ($sites as $site) {
            switch_to_blog($site->blog_id);

            // Delete options for this site
            delete_option('imgpro_cdn_settings');
            delete_option('imgpro_cdn_version');

            restore_current_blog();
        }

        $page++;
    }
}

/**
 * Fires after ImgPro CDN plugin data is deleted
 *
 * Allows other code to perform final cleanup after uninstall
 */
do_action('imgpro_cdn_after_uninstall');
