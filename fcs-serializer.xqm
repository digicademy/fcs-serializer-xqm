xquery version "3.1";

(:
 : MWB | FCS serializer
 :
 : Edited and developed by Patrick D. Brookshire and Ute Recker-Hamm
 : Academy of Sciences and Literature | Mainz
 :
 : xquery module containing various functions used to build CLARIN FCS related elements
 :
 : @author Patrick D. Brookshire
 : @licence MIT
:)

module namespace fcs-serializer="http://mwb.adwmainz.net/exist/fcs/fcs-serializer";

declare namespace fcs = "http://clarin.eu/fcs/resource";

(:~ builds a FCS Resource element with the given params
 : @param $resource-pid the PID of the resource the given hit was found in
 : @param $resource-ref the URL of the resource the given hit was found in
 : @param $fragment-ref the URL of the resource fragment the given hit represents
 : @param $dataViews a sequence of fcs:DataView elements to be included
:)
declare function fcs-serializer:get-resource($resource-pid as xs:string, $resource-ref as xs:anyURI, $fragment-ref as xs:anyURI, $data-views as element(fcs:DataView)*) {
    <fcs:Resource xmlns:fcs="http://clarin.eu/fcs/resource">
        {
            if ($resource-pid eq "") then
                ()
            else
                attribute pid { $resource-pid }
        }
        {
            if ($resource-ref eq "") then
                ()
            else
                attribute ref { $resource-ref }
        }
        <fcs:ResourceFragment ref="{ $fragment-ref }">
            { $data-views }
        </fcs:ResourceFragment>
    </fcs:Resource>
};

(:~ builds a FCS DataView element with the given params
 : @param $preceding-context the text content preceding the hit
 : @param $hit the hit itself
 : @param $following-context the text content following the hit
:)
declare function fcs-serializer:get-generic-hit($preceding-context as xs:string?, $hit as xs:string, $following-context as xs:string?) as element(fcs:DataView) {
    fcs-serializer:get-generic-hit($preceding-context, $hit, $following-context, ())
};

(:~ builds a FCS DataView element with the given params
 : @param $preceding-context the text content preceding the hit
 : @param $hit the hit itself
 : @param $following-context the text content following the hit
 : @param $hit-attrs attributes that should be added to the hit element
:)
declare function fcs-serializer:get-generic-hit($preceding-context as xs:string?, $hit as xs:string, $following-context as xs:string?, $hit-attrs as attribute()*) as element(fcs:DataView) {
    <fcs:DataView type="application/x-clarin-fcs-hits+xml">
        <hits:Result xmlns:hits="http://clarin.eu/fcs/dataview/hits">
            { $preceding-context || " " }
            <hits:Hit>
                { $hit-attrs }
                { $hit }
            </hits:Hit>
            { " " || $following-context }
        </hits:Result>
    </fcs:DataView>
};

(:~ builds a FCS DataView element with the given params
 : @param $items a sequence of item elements that have all layers as child elements and highlighting information as attribute (e.g. `<item highlight="h1"> <layer id="http://www.example.com/ns/fcs/layer/text">test</layer> </item>`) Please note that `@highlight` is used to mark the hit itself and the first layer will be used to build the segments
:)
declare function fcs-serializer:get-advanced-data-view($items as element(item)*) as element(fcs:DataView) {
    <fcs:DataView type="application/x-clarin-fcs-adv+xml">
        <adv:Advanced unit="item" xmlns:adv="http://clarin.eu/fcs/dataview/advanced">
            {
            let $token-lengths := (: pre-calculate token lengths to boost performance :)
                for $token in $items/layer[1]
                return
                    string-length($token)
            return
                <adv:Segments>
                    {
                        for $token-length at $i in $token-lengths
                        let $start :=
                            if ($i eq 1) then
                                1
                            else
                                sum($token-lengths[position() < $i]) + $i
                        let $end := $start + $token-length - 1
                        return
                            <adv:Segment id="s{ $i - 1 }" start="{ $start }" end="{ $end }"/>
                    }
                </adv:Segments>
            }
            <adv:Layers>
                {
                    for $layer-id in distinct-values($items/layer/@id)
                    return
                        <adv:Layer id="{ $layer-id }">
                            {
                                for $item at $i in $items
                                return
                                    <adv:Span ref="s{ $i - 1 }">
                                        { $item/@highlight }
                                        { data($item/layer[@id eq $layer-id]) }
                                    </adv:Span>
                            }
                        </adv:Layer>
                }
            </adv:Layers>
        </adv:Advanced>
    </fcs:DataView>
};
