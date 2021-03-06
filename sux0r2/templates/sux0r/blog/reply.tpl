{capture name=header}

    {$r->jQueryInit(false)}
    {$r->tinyMceComment()}

{/capture}{strip}
{$r->assign('header', $smarty.capture.header)}
{include file=$r->xhtml_header}{/strip}

<div id="proselytizer">

{* Header *}
<div id="header">
    {insert name="userInfo"}
    <div class='clearboth'></div>
</div>

{* Content *}
<div id="middle">

<fieldset>
<legend>{$r->gtext.reply}</legend>

<div class="parentContainer">
<pre>{$parent|trim}</pre>
</div>

<form action="{$r->text.form_url}" name="{$form_name}" method="post" accept-charset="utf-8" >
<input type="hidden" name="token" value="{$token}" />

<input type="hidden" name="parent_id" value="{$parent_id}" />
<input type="hidden" name="integrity" value="{$r->integrityHash($parent_id)}" />
{validate id="integrity" message="integrity failure"}


{if $validate.$form_name.is_error !== false}
<p class="errorWarning">{$r->gtext.form_error} :</p>
{elseif $r->detectPOST()}
<p class="errorWarning">{$r->gtext.form_problem} :</p>
{/if}


<p>
{strip}
    {capture name=error}
    {validate id="title" message=$r->gtext.error_1}
    {/capture}
{/strip}
<label {if $smarty.capture.error}class="error"{/if} >{$r->gtext.title} :</label>
<input type="text" name="title" value="{$title}" class="widerInput" />
{$smarty.capture.error}
</p>

<p>
{strip}
    {capture name=error}
    {validate id="body" message=$r->gtext.error_2}
    {/capture}
{/strip}
<span {if $smarty.capture.error}class="error"{/if}>{$r->gtext.body} : </span> {$smarty.capture.error}
</p>

<p><textarea name="body" class="mceEditor" rows="10" cols="80" >{$body}</textarea></p>

<p>
<label>&nbsp;</label>
<input type="button" class="button" value="{$r->gtext.cancel}" onclick="document.location='{$r->text.back_url}';" />
<input type="submit" class="button" value="{$r->gtext.submit}" />
</p>

</form>
</fieldset>

</div>

</div>

{include file=$r->xhtml_footer}