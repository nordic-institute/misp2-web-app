/*
 * The MIT License
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package ee.aktors.misp2.model;

import java.util.List;

// NB! class is not JPA entity, but is used as a container by EntranceAction
public class TabGrouping implements Comparable<TabGrouping> {
    private final String key;
    private final TopicName topicName;
    private final Topic topic;
    private final List<Producer> producers;
    private final List<Query> queries;
    
    public TabGrouping(Topic topic, TopicName topicName, List<Producer> producers, List<Query> queries) {
        this.key = topic.getName();
        this.topic = topic;
        this.topicName = topicName;
        this.producers = producers;
        this.queries = queries;
    }
    @Override
    public int hashCode() {
        return key != null ? key.hashCode() : 0;
    }
    
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof TabGrouping) {
            TabGrouping other = (TabGrouping)obj;
            return key == null && other.key == null || key != null && other.key != null && key.equals(other.key);
        }
        return false;
    }
    
    public Integer getId() {
        return topic != null ? topic.getId() : null;
    }
    
    public String getName() {
        return topic != null ? topic.getName() : null;
    }
    
    public String getDescription() {
        return topicName != null ? topicName.getDescription() : null;
    }
    
    public String getImagePath() {
        if (topic != null && topic.getName() != null) {
            return "/resources/EE/images/" + topic.getName() + ".png";
        }
        return null;
    }
    
    public List<Producer> getProducers() {
        return producers;
    }
    
    public List<Query> getQueries() {
        return queries;
    }
    
    public String getLabel() {
        String description = getDescription();
        if (description != null) {
            return description;
        } else {
            return getName();
        }
    }
    @Override
    public int compareTo(TabGrouping other) {
        if (this.topic == null && other.topic == null) {
            return 0;
        } else if (this.topic == null) {
            return -1;
        } else if (other.topic == null) {
            return 1;
        } else {
            return this.topic.compareTo(other.topic);
        }
    }
    
}
