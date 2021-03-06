{capture name=header}

    {if $r->isLoggedIn() && $r->bool.bayes}
        {$r->jQueryInit()}
        {$r->genericBayesInterfaceInit()}
    {else}
        {$r->jQueryInit(false)}
    {/if}

    <script type="text/javascript">
    // <![CDATA[
    {if $r->isLoggedIn()}
    // Toggle subscription to a feed
    function toggleSubscription(feed_id) {

        var url = '{$r->url}/modules/feeds/ajax.toggle.php';
        var pars = { id: feed_id };

        $.ajax({
            url: url,
            type: 'post',
            data: pars,
            success: function(data, textStatus, transport) {
              // Toggle images
                var myImage = $.trim(transport.responseText);
                var myClass = 'img.subscription' + feed_id;
                var res = $(myClass);
                for (i = 0; i < res.length; i++) {
                    res[i].src = '{$r->url}/media/{$r->partition}/assets/' + myImage;
                }
            },
            error: function(transport) {
                if ($.trim(transport.responseText).length) {
                    alert(transport.responseText);
                }
            }
        });

    }
    {/if}

    // Set the maximum width of an image
    function maximumWidth(myId, maxW) {
        var pix = document.getElementById(myId).getElementsByTagName('img');
        for (i = 0; i < pix.length; i++) {
            w = pix[i].width;
            h = pix[i].height;
            if (w > maxW) {
                f = 1 - ((w - maxW) / w);
                pix[i].width = w * f;
                pix[i].height = h * f;
            }
        }
    }
    $(window).load(function() {
        maximumWidth('rightside', {#maxPhotoWidth#});
    });
    // ]]>
    </script>

{/capture}{strip}
{$r->assign('header', $smarty.capture.header)}
{include file=$r->xhtml_header}{/strip}

<table id="proselytizer" >
    <tr>
        <td colspan="2" style="vertical-align:top;">
            <div id="header">

                <h1>{$r->gtext.header|lower}</h1>
                {insert name="userInfo"}
                {insert name="navlist"}

            </div>
        </td>
    </tr>
    <tr>
        <td style="vertical-align:top;">
            <div id="leftside">

                <p>{$r->gtext.feeds}</p>

                {if $r->feeds(true, $users_id)}
                <ul>
                    {foreach from=$r->feeds(true, $users_id) item=foo}
                    <li><a href="{$r->makeUrl('/feeds')}/{$foo.id}">{$foo.title}</a></li>
                    {/foreach}
                </ul>

                {else}

                <ul>
                    {foreach from=$r->feeds(false, $users_id) item=foo}
                    <li><a href="{$r->makeUrl('/feeds')}/{$foo.id}">{$foo.title}</a></li>
                    {/foreach}
                </ul>
                {/if}


                <p>{$r->gtext.actions}</p>
                <ul>
                    {if $r->isLoggedIn()}
                    <li><a href="{$r->makeUrl('/feeds/manage')}">{$r->gtext.manage}</a></li>
                    {/if}
                    <li><em><a href="{$r->makeUrl('/feeds/suggest')}">{$r->gtext.suggest} &raquo;</a></em></li>
                </ul>


            </div>
        </td>
        <td style="vertical-align:top;">
            <div id="rightside">

            {if $r->bool.bayes}
            <!-- Category filters -->
            {insert name="bayesFilters" form_url=$r->text.form_url}
            {/if}

            {* Feeds *}
            {if $r->arr.feeds}
            {foreach from=$r->arr.feeds item=foo}

                {capture name=feed}

                    <!-- Content -->
                    <div style="float:left; margin-right:0.5em;">
                    {$r->isSubscribed($foo.rss_feeds_id)}
                    </div>
                    <div style="float:left; margin-bottom: 1em;">
                    {$r->gtext.feed} : {$r->feedLink($foo.rss_feeds_id)}<br />
                    <em>{$r->gtext.published_on} : {$foo.published_on}</em>
                    </div>
                    <div class="clearboth"></div>

                    <div class="rssItem">{insert name="highlight" html=$foo.body_html}</div>

                    <!-- Read more -->
                    <p class="readMore"><a href="{$foo.url}">{$r->gtext.read_more} &raquo;</a></p>

                    {capture name=nbc}{strip}
                        {capture name=document}{$foo.title} {$foo.body_plaintext}{/capture}
                        {if $r->bool.bayes}{$r->genericBayesInterface($foo.id, 'rss_items', 'feeds', $smarty.capture.document)}{/if}
                    {/strip}{/capture}
                    {if $smarty.capture.nbc}
                        <!-- Naive Baysian Classification -->
                        <div class="categoryContainer">
                        {$smarty.capture.nbc}
                        </div>
                    {/if}


                {/capture}

                {capture name=title_HL}{insert name="highlight" html=$foo.title}{/capture}
                {$r->widget($smarty.capture.title_HL, $smarty.capture.feed, $foo.url)}


            {/foreach}
            {else}
                <p>{$r->gtext.not_found}</p>
            {/if}

            {$r->text.pager}

            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2" style="vertical-align:bottom;">
            <div id="footer">
            {$r->copyright()}
            </div>
        </td>
    </tr>
</table>

{if $r->bool.bayes}{insert name="bayesFilterScript"}{/if}

{include file=$r->xhtml_footer}