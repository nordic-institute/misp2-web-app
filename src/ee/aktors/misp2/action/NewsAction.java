/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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

package ee.aktors.misp2.action;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Validateable;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.News;
import ee.aktors.misp2.service.NewsService;

/**
 */
public class NewsAction extends SessionPreparedBaseAction implements Validateable {

    private static final long serialVersionUID = 1L;
    // ------------------- Used internally --------------
    private NewsService nService;
    // ------------------- Form items -------------------
    private News news;
    private Integer newsId;
    private List<News> newsList;
    private static final Logger LOG = LogManager.getLogger(NewsAction.class);

    /**
     * @param service service to inject
     */
    public NewsAction(NewsService service) {
        this.nService = service;
    }
    
    @Override
    public void prepare() throws Exception {
        super.prepare();
        setNewsList(nService.findAllNews(getLocale().getLanguage(), portal));
        if (!newsList.isEmpty() && newsId != null)
            news = nService.findObject(News.class, newsId);
        else {
            news = new News();
            news.setLang(getLocale().getLanguage());
            news.setPortal(portal);
        }
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String editNews() {
        return SUCCESS;
    }

    /**
     * @return ERROR if save fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveNews() {
        if (news != null) {
            try {
                news.setLang(getLocale().getLanguage());
                news.setPortal(portal);
                nService.save(news);
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
                addActionError(getText("text.fail.save"));
                return ERROR;
            }

        }
        return SUCCESS;
    }

    /**
     * @return ERROR if deleting news fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteNews() {
        if (news != null) {
            try {
                nService.remove(news);
                addActionMessage(getText("text.success.delete"));
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
                addActionError(getText("text.fail.delete"));
                return ERROR;
            }
        }
        return SUCCESS;
    }

    @Override
    public void validate() {
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }


    /**
     * @return the news
     */
    public News getNews() {
        return news;
    }

    /**
     * @param newsNew the news to set
     */
    public void setNews(News newsNew) {
        this.news = newsNew;
    }

    /**
     * @return the newsId
     */
    public Integer getNewsId() {
        return newsId;
    }

    /**
     * @param newsIdNew the newsId to set
     */
    public void setNewsId(Integer newsIdNew) {
        this.newsId = newsIdNew;
    }

    /**
     * @return the newsList
     */
    public List<News> getNewsList() {
        return newsList;
    }

    /**
     * @param newsListNew the newsList to set
     */
    public void setNewsList(List<News> newsListNew) {
        this.newsList = newsListNew;
    }

}
