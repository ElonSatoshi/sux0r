<?php

/**
* photos
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
* @author     Dac Chartrand <dac.chartrand@gmail.com>
* @copyright  2008 sux0r development group
* @license    http://www.gnu.org/licenses/agpl.html
*
*/

require_once(dirname(__FILE__) . '/../../includes/suxPhoto.php');
require_once(dirname(__FILE__) . '/../../includes/suxPager.php');
require_once(dirname(__FILE__) . '/../../includes/suxTemplate.php');
require_once('photosRenderer.php');

class photos {

    // Variables
    public $per_page; // Photos per page
    public $gtext = array();
    private $module = 'photos';


    // Objects
    public $tpl;
    public $r;
    private $user;
    private $photo;
    private $pager;


    /**
    * Constructor
    *
    */
    function __construct() {

        $this->tpl = new suxTemplate($this->module); // Template
        $this->r = new photosRenderer($this->module); // Renderer
        $this->gtext = suxFunct::gtext($this->module); // Language
        $this->r->text =& $this->gtext;
        $this->user = new suxUser();
        $this->photo = new suxPhoto();
        $this->pager = new suxPager();

        // This module has config variables, load them
        $this->tpl->config_load('my.conf', $this->module);
        $this->per_page = $this->tpl->get_config_vars('perPage');

    }


    /**
    * List albums
    */
    function listing() {

        $this->tpl->assign_by_ref('r', $this->r);

        // Start pager
        $this->pager->setStart();

        // "Cache Groups" using a vertical bar |
        $cache_id = 'listing|' . $this->pager->start;
        $this->tpl->caching = 0; // TODO, turn cache on

        if (!$this->tpl->is_cached('list.tpl', $cache_id)) {

            $this->pager->setPages($this->photo->countAlbums());
            $this->r->text['pager'] = $this->pager->pageList(suxFunct::makeUrl('/photos'));
            $this->r->pho = $this->photo->getAlbums(null, $this->pager->limit, $this->pager->start);

            if ($this->r->pho == false || !count($this->r->pho))
                $this->tpl->caching = 0; // Nothing to cache, avoid writing to disk

        }

        $this->tpl->display('list.tpl', $cache_id);

    }


    /**
    * List photos in an album
    */
    function album($id) {

        $this->tpl->assign_by_ref('r', $this->r);
        $this->pager->limit = $this->per_page;

        // Start pager
        $this->pager->setStart();

        // "Cache Groups" using a vertical bar |
        $cache_id = "album|{$id}|" . $this->pager->start;
        $this->tpl->caching = 0; // TODO, turn cache on

        if (!$this->tpl->is_cached('album.tpl', $cache_id)) {

            $this->pager->setPages($this->photo->countPhotos($id));
            $this->r->text['pager'] = $this->pager->pageList(suxFunct::makeUrl("/photos/album/{$id}"));
            $this->r->pho = $this->photo->getPhotos($id, $this->pager->limit, $this->pager->start);

            if ($this->r->pho == false || !count($this->r->pho))
                $this->tpl->caching = 0; // Nothing to cache, avoid writing to disk
            else {
                $album = $this->photo->getAlbum($id);
                $this->r->text['album'] = $album['title'];
                $this->r->text['album_url'] = suxFunct::makeUrl('/photos/album/' . $id);
            }

        }

        $this->tpl->display('album.tpl', $cache_id);

    }


    /**
    * View photo
    */
    function view($id) {

        $this->tpl->assign_by_ref('r', $this->r);

        // "Cache Groups" using a vertical bar |
        $cache_id = "view|{$id}|" . $this->pager->start;
        $this->tpl->caching = 0; // TODO, turn cache on

        if (!$this->tpl->is_cached('view.tpl', $cache_id)) {

            $this->r->pho = $this->photo->getPhoto($id);
            if ($this->r->pho == false || !count($this->r->pho))
                $this->tpl->caching = 0; // Nothing to cache, avoid writing to disk
            else {

                $this->r->pho['image'] = suxPhoto::t2fImage($this->r->pho['image']); // Fullsize

                // Album info
                $album = $this->photo->getAlbum($this->r->pho['photoalbums_id']);
                $this->r->text['album'] = $album['title'];

                // Previous, next, and page number
                $prev_id = null;
                $next_id = null;
                $page = 1;
                $query = 'SELECT id FROM photos WHERE photoalbums_id = ? ORDER BY image '; // Same order as suxPhoto->getPhotos()

                $db = suxDB::get();
                $st = $db->prepare($query);
                $st->execute(array($this->r->pho['photoalbums_id']));

                $i = 0;
                while ($prev_next = $st->fetch(PDO::FETCH_ASSOC)) {
                    ++$i;
                    if ($prev_next['id'] == $id) break;
                    if ($i >= $this->per_page) {
                        $i = 0;
                        ++$page;
                    }
                    $prev_id = $prev_next['id'];
                }
                $prev_next = $st->fetch(PDO::FETCH_ASSOC);
                $next_id = $prev_next['id'];

                $this->r->text['prev_id'] = $prev_id;
                $this->r->text['next_id'] = $next_id;
                $this->r->text['back_url'] = suxFunct::makeUrl('photos/album/' . $this->r->pho['photoalbums_id'], array('page' => $page));

            }

        }

        $this->tpl->display('view.tpl', $cache_id);

    }



}


?>