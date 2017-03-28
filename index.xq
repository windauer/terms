xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace terms="http://history.state.gov/ns/xquery/terms" at "/db/apps/terms/modules/terms.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option output:method "html5";
declare option output:media-type "text/html";

let $terms := collection('/db/apps/terms/data')//term
let $view-all := request:get-parameter('view', ())
let $q := request:get-parameter('q', ())
let $remarks := request:get-parameter('remarks', ())
let $id := request:get-parameter('id', ())
let $content := 
    <div>
        <form class="form-inline" action="{$terms:app-base}" method="get">
            <div class="form-group">
                <label for="q" class="control-label">Search Terms</label>
                <input type="text" name="q" id="q" class="form-control" value="{$q}"/>
            </div>
            <div class="form-group">
                <label for="remarks" class="control-label">Search Remarks</label>
                <input type="text" name="remarks" id="remarks" class="form-control" value="{$remarks}"/>
            </div>
            <button type="submit" class="btn btn-default">Submit</button>
        </form>
        {
        if ($view-all or $q or $remarks or $id) then
            ()
        else 
            <div id="about">
                <h2>About</h2>
                <p>“Terms” is a draft-stage database of terms drawn from the lists of terms and abbreviations in many volumes of the <em>Foreign Relations of the United States</em> series. It currently contains {format-number(count($terms), '#,###.##')} terms{(: , consolidated and de-duplicated from {format-number(count(collection('/db/apps/terms/data')//source-url[parent::original]), '#,###.##')} entries, and can be searched using the form above, downloaded as a complete dataset via the <a href="https://github.com/HistoryAtState/people">HistoryAtState/people</a> repository on GitHub, installed on ones computer as part of <a href="https://github.com/HistoryAtState/hsg-project">history.state.gov’s suite of eXist applications</a>, or accessed as an OpenRefine Reconciliation Service (see <a href="#openrefine">OpenRefine</a> below). :) () } To view a table of all terms, select <a href="{$terms:app-base}?view=all">View All</a>. Search hint: Use wildcards like ? (to represent a single character) or * (to represent any number of characters).</p>
            </div>
        }
        {
            if ($view-all) then
                <div>
                    <p>Showing all {count($terms)} terms. (This view shows the term, all unique remarks sorted alphabetically, and the number of sources.)</p>
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <!--<th class="col-md-1">ID</th>-->
                                <th class="col-md-3">Term</th>
                                <th>Remarks</th>
                                <th>Sources</th>
                            </tr>
                        </thead>
                        <tbody>
                        {
                            for $term in $terms
                            let $name := $term/name
                            let $remarks := $term/remarks/remark
                            let $id := $term/id/string()
                            order by $name collation "?lang=en-US" 
                            return
                                <tr>
                                    <!--<td>{$id}</td>-->
                                    <td>
                                        <!--<a href="./id/{$id}">{$name/string()}</a>-->{$name/string()}
                                    </td>
                                    <td>
                                        <ul>{
                                            for $remark in distinct-values($remarks)
                                            order by $remark collation "?lang=en-US" 
                                            return 
                                                <li>{$remark}</li>
                                        }</ul>
                                    </td>
                                    <td>{count($remarks)}</td>
                                </tr>
                        }
                        </tbody>
                    </table>
                </div>
            else ()
        }
        {
            if (($q and $q ne '') or ($remarks and $remarks ne '')) then
                let $query-options := 
                    <options>
                        <default-operator>and</default-operator>
                        <phrase-slop>0</phrase-slop>
                        <leading-wildcard>no</leading-wildcard>
                        <filter-rewrite>yes</filter-rewrite> 
                    </options>
                let $hits := 
                    if ($q ne '' and $remarks ne '') then 
                        (
                            $terms//name[ft:query(., $q, $query-options) or . = $q]/ancestor::term
                            intersect
                            $terms//remark[ft:query(., $remarks, $query-options) or . = $remarks]/ancestor::term
                        )
                    else if ($q ne '') then 
                        $terms//name[ft:query(., $q, $query-options)]/ancestor::term
                    else
                        $terms//remark[ft:query(., $remarks, $query-options)]/ancestor::term
                return
                    <div>
                        <p>{count($hits)} hits for { if ($q ne '') then concat('name “', $q, '”') else ()} { if ($remarks ne '') then concat('remarks “', $remarks, '”') else ()}. {if ($hits) then () else 'Please try again. '} Hint: Use wildcards like ? (to represent a single character) or * (to represent any number of characters).</p>
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <!--<th class="col-md-1">ID</th>-->
                                    <th class="col-md-3">Term</th>
                                    <th>Remarks</th>
                                    <th>Sources</th>
                                </tr>
                            </thead>
                            <tbody>
                            {
                                for $term in $hits
                                let $name := $term/name
                                let $remarks := $term/remarks/remark
                                let $id := $term/id/string()
                                order by $name collation "?lang=en-US" 
                                return
                                    <tr>
                                        <!--<td>{$id}</td>-->
                                        <td>
                                            <!--<a href="./id/{$id}">{$name/string()}</a>-->{$name/string()}
                                        </td>
                                        <td>
                                            <ul>{
                                                for $remark in distinct-values($remarks)
                                                order by $remark collation "?lang=en-US" 
                                                return 
                                                    <li>{$remark}</li>
                                            }</ul>
                                        </td>
                                        <td>{count($remarks)}</td>
                                    </tr>
                            }
                            </tbody>
                        </table>
                    </div>
            else 
                ()
        }
        {
            if ($id and $id ne '') then
                let $term := collection('/db/apps/terms/data')/term[id = $id]
                let $name := $term/name
                let $remarks := $term/remarks/remark
                let $id := $term/id/string()
                order by $name collation "?lang=en-US" 
                return
                    <div id="entry">
                        <h2>{$name/string()}</h2>
                        <ul>
                            <li>ID: {$id}&#0160;<a href="{$terms:app-base}id/{$id}.xml">(View XML)</a></li>
                        </ul>
                        {(:
                            for $authority in $authorities
                            let $record-id := $authority/string()
                            let $authority-name := 'VIAF'
                            let $authority-url := 'https://viaf.org/viaf/'
                            let $url := $authority-url || $record-id
                            return
                                <p>{$authority-name}: <a href="{$url}">{$record-id}</a></p>
                        :)()}
                        {(:
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Original Rendering</th>
                                    <th class="col-md-3">Sources</th>
                                </tr>
                            </thead>
                            <tbody>{
                                for $original in $originals
                                let $name := $original/name
                                let $source-urls := $original/source-url
                                let $sources := 
                                    <ul>{
                                        for $n in $source-urls 
                                        order by $n 
                                        return 
                                            <li>{terms:source-url-to-link($n)}</li>
                                    }</ul>
                                let $serialization-parameters := 
                                    <output:serialization-parameters>
                                        <output:method>html</output:method>
                                        <output:indent>no</output:indent>
                                    </output:serialization-parameters>
                                return
                                    <tr>
                                        <td>{$name/string()}</td>
                                        <td>
                                            <a tabindex="0" class="btn btn-default" role="button" data-toggle="popover" data-trigger="focus" title="{count($source-urls)} Sources" data-content="{serialize($sources, $serialization-parameters)}" data-html="true">{count($source-urls)}</a>
                                        </td>
                                    </tr>
                            }</tbody>
                        </table>
                        :)()}
                        {(:
                            if ($titles) then 
                                <table class="table table-bordered table-striped">
                                    <thead>
                                        <tr>
                                            <th>Titles Extracted from Name Field</th>
                                            <th class="col-md-3">Sources</th>
                                        </tr>
                                    </thead>
                                    <tbody>{
                                        for $original in $titles
                                        let $name := $original/name
                                        let $source-urls := $original/source-url
                                        let $sources := 
                                            <ul>{
                                                for $n in $source-urls 
                                                order by $n 
                                                return 
                                                    <li>{terms:source-url-to-link($n)}</li>
                                            }</ul>
                                        let $serialization-parameters := 
                                            <output:serialization-parameters>
                                                <output:method>html</output:method>
                                                <output:indent>no</output:indent>
                                            </output:serialization-parameters>
                                        return
                                            <tr>
                                                <td>{$name/string()}</td>
                                                <td>
                                                    <a tabindex="0" class="btn btn-default" role="button" data-toggle="popover" data-trigger="focus" title="{count($source-urls)} Sources" data-content="{serialize($sources, $serialization-parameters)}" data-html="true">{count($source-urls)}</a>
                                                </td>
                                            </tr>
                                    }</tbody>
                                </table>
                            else 
                                ()
                        :)()}
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Remarks</th>
                                    <th class="col-md-3">Sources</th>
                                </tr>
                            </thead>
                            <tbody>{
                                for $remark in $remarks
                                let $p := $remark/p
                                let $source-urls := $remark/source-url
                                return
                                    <tr>
                                        <td>{$p/string()}</td>
                                        <td><ul class="list-unstyled">{
                                            for $n in $source-urls 
                                            order by $n 
                                            return 
                                                <li>{terms:source-url-to-link($n)}</li>
                                        }</ul></td>
                                    </tr>
                            }</tbody>
                        </table>
                        <script>$(function () {{ $('[data-toggle="popover"]').popover() }})</script>
                    </div>
            else ()
        }
    </div>
let $site-title := 'Terms'
let $page-title := $content//h2
let $titles := if ($page-title = 'About') then $site-title else ($site-title, $page-title)
return 
    (
        (: strip search box from google refine results :)
        if (contains(request:get-header('Referer'), ':3333/')) then 
            terms:wrap-html($content//div[@id = 'entry'], $titles)
        else
            terms:wrap-html($content, $titles)
    )