
# fcs-serializer-xqm

This software package provides an XQuery module developed at the Digital Academy of the Academy of Sciences and Literature | Mainz that may be used to build elements of an [CLARIN FCS endpoint](https://office.clarin.eu/v/CE-2017-1046-FCS-Specification-v20230426.pdf).

# Requirements
The module was developed and tested to be used with the versions 3.1 of XQuery.

# How to Use
1. Import the module into your own XQuery script or module in the usual way:

```xquery
import module namespace fcs-serializer="http://mwb.adwmainz.net/exist/fcs/fcs-serializer" at "PATH/TO/fcs-serializer.xqm";
```

2. Use the following functions:
  * `fcs-serializer:get-advanced-data-view`
  * `fcs-serializer:get-generic-hit#3`
  * `fcs-serializer:get-generic-hit#4`
  * `fcs-serializer:get-resource`

## fcs-serializer:get-advanced-data-view

```xquery
fcs-serializer:get-advanced-data-view($items as element(item)*) as element(fcs:DataView)
```

transforms a sequence of more compact custom item elements [matching the provided schema](schema/annotatedItem.rng) into the standOff `fcs:DataView` element

### Parameters:

**$items***  sequence of `item` elements that have all layers as child elements and highlighting information as attribute. Please note that `@highlight` is used to mark the hit itself and the first layer will be used to build the segments - e.g.

```xquery
(
  <item>
    <layer id="http://www.example.com/ns/fcs/layer/text">Lorem</layer>
    <layer id="http://www.example.com/ns/fcs/layer/lemma">lorem</layer>
  </item>,
  <item highlight="h1">
    <layer id="http://www.example.com/ns/fcs/layer/text">ipsum</layer>
    <layer id="http://www.example.com/ns/fcs/layer/lemma">ipsum</layer>
  </item>
)
```

### Returns:

**element(fcs:DataView)** the proper FCS equivalent - e.g.

```xml
<fcs:DataView xmlns:fcs="http://clarin.eu/fcs/resource" type="application/x-clarin-fcs-adv+xml">
    <adv:Advanced xmlns:adv="http://clarin.eu/fcs/dataview/advanced" unit="item">
        <adv:Segments>
            <adv:Segment id="s0" start="1" end="5"/>
            <adv:Segment id="s1" start="7" end="11"/>
        </adv:Segments>
        <adv:Layers>
            <adv:Layer id="http://www.example.com/ns/fcs/layer/text">
                <adv:Span ref="s0">Lorem</adv:Span>
                <adv:Span ref="s1" highlight="h1">ipsum</adv:Span>
            </adv:Layer>
            <adv:Layer id="http://www.example.com/ns/fcs/layer/lemma">
                <adv:Span ref="s0">lorem</adv:Span>
                <adv:Span ref="s1" highlight="h1">ipsum</adv:Span>
            </adv:Layer>
        </adv:Layers>
    </adv:Advanced>
</fcs:DataView>
```

---

# License
The software is published under the terms of the MIT license.


# Research Software Engineering and Development

Copyright 2023 <a href="https://orcid.org/0000-0002-5843-7577">Patrick Daniel Brookshire</a>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
