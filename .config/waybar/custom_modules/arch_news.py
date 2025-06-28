#!/usr/bin/env python3

import json
import sys
from datetime import datetime, timedelta
import feedparser

class ArchNewsModule:
    def __init__(self, days=7):
        self.days = days
        self.rss_url = "https://archlinux.org/feeds/news/"
        self.news_data = {"count": 0, "headlines": []}

    def fetch_news(self):
        try:
            headers = {'User-Agent': 'Waybar-ArchNews/1.0'}
            feed = feedparser.parse(self.rss_url)

            if feed.bozo:
                return {"count": 0, "headlines": ["Error: Failed to parse RSS feed"]}

            cutoff_date = datetime.now() - timedelta(days=self.days)
            recent_news = []

            for entry in feed.entries:
                if hasattr(entry, 'published_parsed') and entry.published_parsed:
                    pub_date = datetime(*entry.published_parsed[:6])
                elif hasattr(entry, 'updated_parsed') and entry.updated_parsed:
                    pub_date = datetime(*entry.updated_parsed[:6])
                else:
                    continue

                if pub_date >= cutoff_date:
                    recent_news.append({
                        'title': entry.title,
                        'date': pub_date.strftime('%Y-%m-%d %H:%M'),
                        'link': getattr(entry, 'link', '')
                    })

            recent_news.sort(key=lambda x: x['date'], reverse=True)

            return {
                "count": len(recent_news),
                "headlines": recent_news
            }

        except Exception as e:
            return {"count": 0, "headlines": [f"Error: {str(e)}"]}

    def get_waybar_output(self):
        self.news_data = self.fetch_news()

        if self.news_data["headlines"]:
            if isinstance(self.news_data["headlines"][0], dict):
                tooltip = "\n\n".join(
                    f" <span color=\"#a6e3a1\">{item['title']} ({item['date']})</span>"
                    for item in self.news_data["headlines"]
                )
            else:
                tooltip = "\n".join(self.news_data["headlines"])
        else:
            tooltip = f"No Arch Linux news in the last {self.days} days"

        count = self.news_data["count"]
        text = f" {count}"
        css_class = "arch_news_active" if count > 0 else "arch_news_inactive"

        return {
            "text": text,
            "tooltip": tooltip,
            "class": css_class,
            "percentage": min(count * 10, 100)
        }

def main():
    days = 7
    if len(sys.argv) > 1:
        try:
            days = int(sys.argv[1])
        except ValueError:
            days = 7

    module = ArchNewsModule(days=days)

    try:
        output = module.get_waybar_output()
        print(json.dumps(output))
        sys.stdout.flush()
    except Exception as e:
        error_output = {
            "text": " ✗",
            "tooltip": f"Error: {str(e)}",
            "class": "arch-news-error"
        }
        print(json.dumps(error_output))
        sys.exit(1)

if __name__ == "__main__":
    main()
