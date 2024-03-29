//
//  ParseDynamoKievUa.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ParseSiteContent.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "ArticleContent.h"
#import "TeamResults.h"
#import "PlayerStats.h"
#import "UserComment.h"
#import "MatchScoreInfo.h"
#import "PlayoffsMatchScoreInfo.h"
#import "TextContentElement.h"
#import "VideoArticleElement.h"
#import "ImageArticleElement.h"


@implementation ParseSiteContent

+ (NSMutableArray *)parseNewslinePage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *articles;
    if(bodyNode && !error){
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSMutableArray *postsBetweenLiTags = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
        articles = [[NSMutableArray alloc] init];
        NSString *childNodeContent;
        for (HTMLNode *liNode in postsBetweenLiTags) {
            if ([liNode findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
                NSMutableArray *children = [NSMutableArray arrayWithArray:[liNode children]];
                ArticleContent *article = [[ArticleContent alloc] init];
                for (NSInteger i = children.count-1; i >= 0; i--){
                    if ([[children[i] tagName] isEqualToString:@"text"]) {
                        [children removeObjectAtIndex:i];
                    }
                }
                article.commentsCount = [[[liNode findChildOfClass:@"comments"] contents] integerValue];
                for (HTMLNode *node in children) {
                    childNodeContent = [[node findChildTag:@"a"] getAttributeNamed:@"href"];
                    if (childNodeContent) {
                        if ([childNodeContent rangeOfString:@"#"].location == NSNotFound) {
                            if ([childNodeContent rangeOfString:@"news"].location != NSNotFound) {
                                article.articleType = NEWS_TYPE;
                            } else{
                                article.articleType = ARTICLE_TYPE;
                            }
                            
                            NSRange idRange = NSMakeRange(childNodeContent.length - 11, 6);
                            article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
                        }
                    }
                    childNodeContent = [[node findChildTag:@"i"] contents];
                    if (childNodeContent) {
                        article.title = childNodeContent;
                    }
                    HTMLNode *imgNode = [node findChildTag:@"img"];
                    if ([[imgNode getAttributeNamed:@"width"] isEqualToString:@"160"]) {
                        article.mainImageLink = [imgNode getAttributeNamed:@"src"];
                    }
                    childNodeContent = [[node findChildTag:@"small"] contents];
                    if (childNodeContent) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"dd.MM.yyyy, HH:mm"];
                        NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
                        article.publishedDate = pubDate;
                    }
//                    HTMLNode *divContent = [[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent];
//                    if (divContent) {
//                        NSArray *pNodes = [divContent findChildTags:@"p"];
//                        NSMutableString *articleContent = [[NSMutableString alloc] init];
//                        for (HTMLNode *pNode in pNodes) {
//                            if (![[pNode allContents] hasPrefix:@"Читать"]) {
//                                [articleContent appendString:[pNode allContents]];
//                                [articleContent appendString:@"\n"];
//                            }
//                        }
////                        article.content = articleContent;
//                    }
                }
                article.isLoaded = NO;
                [articles addObject:article];
            }
        }
    }
    return articles;
}

+(void)parseArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    if(bodyNode && !error){
        NSArray *contentTags = [[bodyNode findChildOfClass:@"content"] children];
        article.content = [[NSMutableArray alloc] init];
        for (HTMLNode *contentNode in contentTags) {
            NSString *classOfTag = [contentNode className];
            if (![classOfTag hasPrefix:@"banner"]) {
                NSString *nameOfTag = [contentNode tagName];
                if (![nameOfTag isEqualToString:@"text"]) {
                    if ([nameOfTag isEqualToString:@"p"]) {
                        NSString *content = [contentNode allContents];
                        if (content.length != 0) {
                            TextContentElement *textElement = [[TextContentElement alloc] init];
                            if ([contentNode findChildTag:@"strong"]) {
                                textElement.isBold = YES;
                            }
                            textElement.textContent = content;
                            [article.content addObject:textElement];
                        }
                        
                    } else if ([classOfTag hasPrefix:@"image"]) {
                        ImageArticleElement *image = [[ImageArticleElement alloc] init];
                        image.URL = [[contentNode findChildTag:@"img"] getAttributeNamed:@"src"];
                        image.title = [[contentNode findChildOfClass:@"pictitle"] allContents];
                        [article.content addObject:image];
                    } else if ([classOfTag isEqualToString:@"source"]) {
                        TextContentElement *textElement = [[TextContentElement alloc] init];
                        textElement.textContent = [contentNode allContents];
                        textElement.isSource = YES;
                        [article.content addObject:textElement];
                    }
                }
            }
        }
        article.isLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
    }
}

+ (NSMutableArray *)parseBlogsPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *articles;
    
    if(bodyNode && !error){
        articles = [[NSMutableArray alloc] init];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSMutableArray *posts = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
        NSString *childNodeContent;
        for (NSInteger i = posts.count-1; i >= 0; i--){
            HTMLNode *node = posts[i];
            if (![node findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
                [posts removeObjectAtIndex:i];
            }
        }
        for (HTMLNode *node in posts) {
            ArticleContent *article = [[ArticleContent alloc] init];
            article.articleType = BLOGS_TYPE;
            article.isLoaded = NO;
            HTMLNode *commentsNode = [node findChildWithAttribute:@"class" matchingName:@"comments" allowPartial:NO];
            childNodeContent = [commentsNode getAttributeNamed:@"href"];
            if (childNodeContent) {
                NSRange idRange = NSMakeRange(childNodeContent.length - 20, 6);
                article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
            }
            article.commentsCount = [[commentsNode contents] integerValue];
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@" post-name" allowPartial:NO] contents];
            if (childNodeContent) {
                article.title = childNodeContent;
            }
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@"fan-zona-text post-name" allowPartial:NO]contents];
            if (childNodeContent) {
                article.title = childNodeContent;
            }
            HTMLNode *author = [node findChildWithAttribute:@"width" matchingName:@"18" allowPartial:NO];
            if (author) {
                childNodeContent = [author getAttributeNamed:@"src"];
                if (childNodeContent) {
                    article.mainImageLink = childNodeContent;
                }
                childNodeContent = [author getAttributeNamed:@"alt"];
                if (childNodeContent) {
                    article.userName = childNodeContent;
                }
                childNodeContent = [[[[author parent] nextSibling] nextSibling] contents];
                if (childNodeContent) {
                    article.userName = [NSString stringWithFormat:@"%@ - %@", article.userName, childNodeContent];
                }
            }
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@"muted" allowPartial:NO] allContents];
            if (childNodeContent) {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd.MM.yyyy, HH:mm"];
                NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
                article.publishedDate = pubDate;
            }
            [articles addObject:article];
        }
    }
    return articles;
}

+ (NSMutableArray *)parseMatchCenterFile:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *content;
    if (bodyNode && !error) {
        NSArray *tournaments = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"match-center__group active" allowPartial:NO];
        if (tournaments.count != 0) {
            content = [[NSMutableArray alloc] init];
            NSString *childNodeContent;
            for (HTMLNode *tournamentNode in tournaments) {
                NSMutableArray *tournament = [[NSMutableArray alloc] init];
                NSArray *matches = [tournamentNode findChildTags:@"tr"];
                childNodeContent = [[tournamentNode findChildWithAttribute:@"class" matchingName:@"match-center__head" allowPartial:NO] allContents];
                NSString *tournamentName = [childNodeContent stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                for (HTMLNode *matchNode in matches) {
                    MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                    match.tournament = tournamentName;
                    NSArray *matchContent = [matchNode findChildrenWithAttribute:@"class" matchingName:@"news-live-link_main news-live-link_main_h22" allowPartial:NO];
                    match.homeTeam = [[[matchContent firstObject] allContents] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    HTMLNode *scoreNode = [matchNode findChildTag:@"strong"];
                    childNodeContent = [[scoreNode nextSibling] allContents];
                    NSRange spaceRange = [childNodeContent rangeOfString:@" "];
                    if (spaceRange.location == 0) {
                        match.guestTeam = [childNodeContent substringFromIndex:1];
                    } else {
                        match.guestTeam = childNodeContent;
                    }
                    childNodeContent = [scoreNode contents];
                
                    if([childNodeContent rangeOfString:@"-"].location == NSNotFound){
                        childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSRange dashLocation = [childNodeContent rangeOfString:@":"];
                        match.guestTeamScore = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
                        match.homeTeamScore = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
                    } else {
                        match.guestTeamScore = -1;
                        match.homeTeamScore = -1;
                    }
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    format.dateFormat = @"dd MMMM HH:mm";
                    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
                    childNodeContent = [[matchNode findChildWithAttribute:@"class" matchingName:@"date-cell" allowPartial:NO] allContents];
                    NSDate *temp = [format dateFromString:childNodeContent];
                    if (temp) {
                        format.dateFormat = @"dd.MM  HH:mm";
                        match.date = [format stringFromDate:temp];
                    } else {
                        match.date = childNodeContent;
                    }
                    match.link = [[matchNode findChildOfClass:@"bl-match"] getAttributeNamed:@"href"];
                    [tournament addObject:match];
                }
                [content addObject:tournament];
            }
        }
    }
    return content;
}

+(NSMutableArray *)parseLegueTablePage:(NSString *)page{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *teams;
    if (bodyNode && !error) {
        teams = [[NSMutableArray alloc] init];
        NSArray *tours = [[bodyNode findChildOfClass:@"rightcol span4"] findChildrenOfClass:@"tour"];
        HTMLNode *lastPlayedTourNode = tours[0];
        NSString *pNodeContents = [[lastPlayedTourNode findChildTag:@"p"] allContents];
        NSRange openBracketRange = [pNodeContents rangeOfString:@"("];
        NSRange dotRange = [pNodeContents rangeOfString:@"."];
        NSString *lastPlayedTourStr;
        if(dotRange.location != NSNotFound){
            lastPlayedTourStr = [pNodeContents substringWithRange:NSMakeRange(openBracketRange.location + 1, dotRange.location - openBracketRange.location - 1)];        //fix it to get right value in non ukrainian championship!
        }
        NSNumber *lastPlayedTour = [[NSNumber alloc] initWithInteger:[lastPlayedTourStr integerValue]];
        HTMLNode *tbodyNode = [bodyNode findChildTag:@"tbody"];
        NSArray *teamsNode = [tbodyNode findChildTags:@"tr"];
        NSString *childNodeContent;
        for (HTMLNode *teamNode in teamsNode) {
            TeamResults *team = [[TeamResults alloc] init];
            NSArray *tdNodes = [teamNode findChildTags:@"td"];
            team.position = [[tdNodes[0] contents] integerValue];
            team.imageLink = [[tdNodes[1] findChildTag:@"img"] getAttributeNamed:@"src"];
            team.name = [[tdNodes[1] findChildTag:@"strong"] contents];
            team.city = [[tdNodes[1] findChildWithAttribute:@"class" matchingName:@"table-championship__city" allowPartial:NO] contents];
            team.gamesPlayed = [[tdNodes[2]contents] integerValue];
            team.wins = [[tdNodes[3]contents] integerValue];
            team.draws = [[tdNodes[4]contents] integerValue];
            team.defeats = [[tdNodes[5]contents] integerValue];
            childNodeContent = [tdNodes[6]contents];
            NSRange dashLocation = [childNodeContent rangeOfString:@"-"];
            team.goalsScored = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
            team.goalsAgainst = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
            team.points = [[tdNodes[7]contents] integerValue];
            [teams addObject:team];
        }
        [teams addObject:lastPlayedTour];
    }
    return teams;
}

+(NSMutableArray *)parseLegueSchedulePage:(NSString *)page{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *tours;
    if (bodyNode && !error) {
        tours = [[NSMutableArray alloc] init];
        NSArray *tourPlayedNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"tour played wide_span4 span4" allowPartial:NO];
        NSMutableArray *tourNodes = [NSMutableArray arrayWithArray:tourPlayedNodes];
        NSArray *tourNotPlayedNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"tour  wide_span4 span4" allowPartial:NO];
        [tourNodes addObjectsFromArray:tourNotPlayedNodes];
        NSString *childNodeContent;
        for (HTMLNode *tourNode in tourNodes) {
            NSArray *trNodes = [tourNode findChildTags:@"tr"];
            NSMutableArray *singleTourMatches = [[NSMutableArray alloc] init];
            for (HTMLNode *tr in trNodes) {
                MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                NSArray *tdNodes = [tr findChildTags:@"td"];
                match.homeTeam = [[tdNodes firstObject] allContents];
                match.guestTeam = [[tdNodes lastObject] allContents];
                childNodeContent = [[tr findChildOfClass:@"result"] allContents];
                if (childNodeContent) {
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSRange dashLocation = [childNodeContent rangeOfString:@":"];
                    match.homeTeamScore = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
                    match.guestTeamScore = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
                }
                childNodeContent = [[tr findChildOfClass:@"date"] allContents];
                if (childNodeContent) {
                    match.date = childNodeContent;
                    match.homeTeamScore = match.guestTeamScore = -1;
                }
                [singleTourMatches addObject:match];
            }
            [tours addObject:singleTourMatches];
        }
    }
    return tours;
}

+(NSMutableArray *)parseLegueScorersPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *players;
    if (bodyNode && !error) {
        players = [[NSMutableArray alloc] init];
        NSArray *tbodyNode = [[[bodyNode findChildOfClass:@"table-stats"] findChildTag:@"tbody"] findChildTags:@"tr"];
        for (HTMLNode *node in tbodyNode) {
            PlayerStats *player = [[PlayerStats alloc] init];
            NSArray *tdNodes = [node findChildTags:@"td"];
            NSString *nameAndTeam = [tdNodes[1] allContents];
            NSRange bracketsRange = [nameAndTeam rangeOfString:@"("];
            player.name = [nameAndTeam substringToIndex:bracketsRange.location - 1];
            bracketsRange.location++;
            bracketsRange.length = nameAndTeam.length - 2 - bracketsRange.location;
            player.team = [nameAndTeam substringWithRange:bracketsRange];
            player.goalsScored = [[tdNodes[2] contents] integerValue];
            player.homeGoals = [[tdNodes[3] contents] integerValue];
            player.guestGoals = [[tdNodes[4] contents] integerValue];
            player.penaltyScored = [[tdNodes[5] contents] integerValue];
            [players addObject:player];
        }
    }
    return players;
}

+(MatchScoreInfo *)parseCentralMatchPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    MatchScoreInfo *centralMatch;
    if (bodyNode && !error) {
        HTMLNode *bMatch = [bodyNode findChildOfClass:@"block-border"];
        if(bMatch){
            centralMatch = [[MatchScoreInfo alloc] init];
            centralMatch.tournament = [[bMatch findChildOfClass:@"b-match__head"] contents];
            NSArray *teamNameNodes = [bMatch findChildrenOfClass:@"b-match__body__name"];
            centralMatch.homeTeam = [teamNameNodes[0] contents];
            centralMatch.guestTeam = [teamNameNodes[1] contents];
            NSArray *teamCityNodes = [bMatch findChildrenOfClass:@"b-match__body__city"];
            NSString *temp = [[teamCityNodes[0] contents] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if(temp.length > 3){
                centralMatch.homeTeamCity = temp;
            }
            temp = [[teamCityNodes[1] contents] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if(temp.length > 3){
                centralMatch.guestTeamCity = temp;
            }
            centralMatch.date = [[bMatch findChildOfClass:@"b-match__body-info"] contents];
            HTMLNode *teamNode = [bMatch findChildOfClass:@"b-match__body__left_pad"];
            NSString *matchScore = [[teamNode findChildWithAttribute:@"class" matchingName:@"b-counter-widg_num" allowPartial:YES] getAttributeNamed:@"class"];
            if (matchScore) {
                NSRange numRange = [matchScore rangeOfString:@"num"];
                centralMatch.homeTeamScore = [[matchScore substringFromIndex:numRange.location + 4] integerValue];
                matchScore = [[teamNode findChildOfClass:@"goal-name-wr"] allContents];
                if (matchScore) {
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    matchScore = [matchScore substringWithRange:NSMakeRange(2, matchScore.length - 4)];
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    centralMatch.homeTeamScorers = [ParseSiteContent nameOfScorersToArray:matchScore];
                }
                teamNode = [bMatch findChildOfClass:@"b-match__body__right_pad"];
                matchScore = [[teamNode findChildWithAttribute:@"class" matchingName:@"b-counter-widg_num" allowPartial:YES] getAttributeNamed:@"class"];
                numRange = [matchScore rangeOfString:@"num"];
                centralMatch.guestTeamScore = [[matchScore substringFromIndex:numRange.location + 4] integerValue];
                matchScore = [[teamNode findChildOfClass:@"goal-name-wr"] allContents];
                if (matchScore) {
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    matchScore = [matchScore substringWithRange:NSMakeRange(2, matchScore.length - 4)];
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    centralMatch.guestTeamScorers = [ParseSiteContent nameOfScorersToArray:matchScore];
                }
            } else {
                centralMatch.homeTeamScore = centralMatch.guestTeamScore = -1;
            }
        }
    }
    return centralMatch;
}

+(NSMutableDictionary *)parseTableAndCalendarPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableDictionary *parsingResults;
    if (bodyNode) {
        parsingResults = [[NSMutableDictionary alloc] init];
        [self parseTableForGroupedTournamentsFromBodyNode:bodyNode savingTo:parsingResults];
        [self parseCalendarForGroupedTournamentsFromBodyNode:bodyNode savingTo:parsingResults];
    }
    return parsingResults;
}

+(NSArray *)nameOfScorersToArray:(NSString *)scorers{
    NSMutableArray *scorersArray = [[NSMutableArray alloc] init];
    NSRange nextLineSymbolRange = [scorers rangeOfString:@"\n"];
    while (nextLineSymbolRange.location != NSNotFound) {
        [scorersArray addObject:[scorers substringToIndex:nextLineSymbolRange.location]];
        scorers = [scorers substringFromIndex:nextLineSymbolRange.location + 1];
        nextLineSymbolRange = [scorers rangeOfString:@"\n"];
    }
    [scorersArray addObject:scorers];
    return scorersArray;
}

+(void)parseMatchDetailInfoPage:(NSString *)page savingTo:(MatchScoreInfo *)match{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
    } else {
        HTMLNode *bodyNode = [parser body];
        HTMLNode *homeTeamGoalsNode = [[bodyNode findChildOfClass:@"b-match__body__left"] findChildOfClass:@"b-match__goals"];
        NSArray *goalsNodes = [homeTeamGoalsNode findChildTags:@"li"];
        match.homeTeamScorers = [self getScorerDeletingName:goalsNodes];
        HTMLNode *guestTeamGoalsNode = [[bodyNode findChildOfClass:@"b-match__body__right"] findChildOfClass:@"b-match__goals b-match__goals_away"];
        goalsNodes = [guestTeamGoalsNode findChildTags:@"li"];
        match.guestTeamScorers = [self getScorerDeletingName:goalsNodes];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MatchDetailsPrepared" object:nil];
}

+(NSMutableArray *)getScorerDeletingName:(NSArray *)goalsNodes{
    NSMutableArray *scorers = [[NSMutableArray alloc] init];
    for (HTMLNode *liNode in goalsNodes) {
        NSString *scorer = [[liNode allContents] stringByReplacingOccurrencesOfString:@"- " withString:@""];
        NSString *penalty = @"";
        NSRange penaltyRange = [scorer rangeOfString:@" (п.)"];
        if (penaltyRange.location != NSNotFound) {
            penalty = [scorer substringFromIndex:penaltyRange.location];
            scorer = [scorer substringToIndex:penaltyRange.location];
        }
        if([scorer rangeOfString:@"."].location + 1 != scorer.length){
            NSRange spaceRange = [scorer rangeOfString:@" "];
            NSString *time = [scorer substringToIndex:spaceRange.location];
            NSString *scorerName = [scorer substringFromIndex:spaceRange.location + 1];
            spaceRange = [scorerName rangeOfString:@" "];
            if (spaceRange.location != NSNotFound) {
                scorerName = [scorerName substringFromIndex:spaceRange.location + 1];
            }
            scorer = [NSString stringWithFormat:@"%@ %@%@", time, scorerName, penalty];
        }
        [scorers addObject:scorer];
    }
    return scorers;
}

+(void)parseCommentsPage:(NSString *)page savingTo:(ArticleContent *)article{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    if(!bodyNode){
        article.commentsContainer.isAllCommentsLoaded = YES;
    } else {
        if (error) {
            NSLog(@"error:%@",error.description);
        } else {
            HTMLNode *bestCommentNode = [bodyNode findChildOfClass:@"well"];
            if(bestCommentNode){
                article.commentsContainer.bestComment = [[UserComment alloc] init];
                [ParseSiteContent parseCommentNode:bestCommentNode savingTo:article.commentsContainer.bestComment];
            }
            HTMLNode *loadCommentsNode =[bodyNode findChildWithAttribute:@"href" matchingName:@"#load-comments" allowPartial:NO];
            if([loadCommentsNode getAttributeNamed:@"style"]){
                article.commentsContainer.isAllCommentsLoaded = YES;
            } else {
                article.commentsContainer.isAllCommentsLoaded = NO;
            }
            NSArray *liNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"comment-level" allowPartial:YES];
            NSMutableArray *newComments = [[NSMutableArray alloc] initWithArray:article.commentsContainer.comments];
            if (liNodes.count != 0) {
                article.commentsContainer.comments = [[NSMutableArray alloc] init];
                NSString *temp;
                for (HTMLNode *liNode in liNodes) {
                    UserComment *comment = [[UserComment alloc] init];
                    if([liNode findChildWithAttribute:@"class" matchingName:@"show-comment-link" allowPartial:NO]){
                        comment.isHidden = YES;
                    }
                    temp = [liNode className];
                    NSRange levelWordRange = [temp rangeOfString:@"level-"];
                    NSRange levelNumberRange = NSMakeRange(levelWordRange.location + levelWordRange.length, 1);
                    comment.level = [[temp substringWithRange:levelNumberRange] integerValue];
                    if ([liNode findChildOfClass:@"deleted"]) {
                        comment.content = @"Комментарий удален";
                        comment.isDeleted = YES;
                        [article.commentsContainer.comments addObject:comment];
                    } else {
                        [ParseSiteContent parseCommentNode:liNode savingTo:comment];
                        [newComments addObject:comment];
                    }
                }
            }
            article.commentsContainer.comments = newComments;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentsDownloaded" object:nil];
}

+(void)parseCommentNode:(HTMLNode *)node savingTo:(UserComment *)comment{
    NSString *temp;
    if(!comment){
        comment = [[UserComment alloc] init];
    }
    comment.username = [[node findChildOfClass:@"user"] contents];
    
    temp = [[node findChildOfClass:@"comment-info"] allContents];
    NSRange openBracketRange = [temp rangeOfString:@"("];
    NSRange closeBracketRange = [temp rangeOfString:@")"];
    temp = [temp substringWithRange:NSMakeRange(openBracketRange.location + 1, closeBracketRange.location - openBracketRange.location - 1)];
    if(!comment.username){
        comment.username = temp;
    } else {
        comment.username = [NSString stringWithFormat:@"%@ - %@", comment.username, temp];
    }
    comment.userLink = [[node findChildOfClass:@"user"] getAttributeNamed:@"href"];
    temp = [[node findChildWithAttribute:@"class" matchingName:@"js-title-name" allowPartial:YES] contents];
    NSRange spaceRange = [temp rangeOfString:@" "];
    if(spaceRange.location != NSNotFound){
        comment.userStatus = [temp substringToIndex:spaceRange.location];
    } else {
        comment.userStatus = temp;
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"dd.MM.yyyy HH:mm";
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
    temp = [[[node findChildOfClass:@"pull-right"] findChildTag:@"span"] contents];
    NSDate *convertationResult = [format dateFromString:temp];
    if (convertationResult) {
        format.dateFormat = @"dd.MM HH:mm";
        comment.date = [format stringFromDate:convertationResult];
    } else {
        comment.date = temp;
    }
    temp = [[node findChildOfClass:@"comment-content"] allContents];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    comment.content = temp;
    HTMLNode *tempNode = [node findChildWithAttribute:@"class" matchingName:@"karma" allowPartial:YES];
    comment.rating = [[[tempNode findChildWithAttribute:@"class" matchingName:@"rank" allowPartial:YES] contents] integerValue];
}

+(void)parseTableForGroupedTournamentsFromBodyNode:(HTMLNode *)bodyNode savingTo:(NSMutableDictionary *)parsingResults{
    NSArray *tbodyNodes = [bodyNode findChildTags:@"tbody"];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for (HTMLNode *tbody in tbodyNodes) {
        NSString *childNodeContent;
        NSMutableArray *teams = [[NSMutableArray alloc] initWithCapacity:4];
        NSArray *teamsNode = [tbody findChildrenOfClass:@"leader"];
        for (HTMLNode *teamNode in teamsNode) {
            TeamResults *team = [[TeamResults alloc] init];
            NSArray *tdNodes = [teamNode findChildTags:@"td"];
            childNodeContent = [[tdNodes[0] findChildTag:@"strong"] allContents];
            NSRange spaceRange = [childNodeContent rangeOfString:@" "];
            if (spaceRange.location == NSNotFound) {
                team.name = childNodeContent;
                childNodeContent = [[tdNodes[0] findChildTag:@"span"] allContents];
                if ([childNodeContent hasPrefix:@" "]) {
                    childNodeContent = [childNodeContent substringFromIndex:1];
                }
                NSRange spaceLocation = [childNodeContent rangeOfString:@" "];
                team.city = [childNodeContent substringFromIndex:spaceLocation.location+1];
            } else {
                team.name = [childNodeContent substringToIndex:spaceRange.location];
                childNodeContent = [[tdNodes[0] findChildTag:@"span"] allContents];
                NSRange teamNameRange = [childNodeContent rangeOfString:[NSString stringWithFormat:@"%@ ", team.name]];
                childNodeContent = [childNodeContent substringFromIndex:teamNameRange.length + 1];
                team.city = [childNodeContent substringFromIndex:[childNodeContent rangeOfString:@" "].location + 1];
            }
            team.gamesPlayed = [[tdNodes[1]contents] integerValue];
            team.wins = [[tdNodes[2]contents] integerValue];
            team.draws = [[tdNodes[3]contents] integerValue];
            team.defeats = [[tdNodes[4]contents] integerValue];
            childNodeContent = [tdNodes[5]contents];
            NSRange dashLocation = [childNodeContent rangeOfString:@"-"];
            
            team.goalsScored = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
            team.goalsAgainst = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
            team.points = [[[tdNodes[6] findChildTag:@"strong"] contents] integerValue];
            [teams addObject:team];
        }
        [groups addObject:teams];
    }
    [parsingResults setObject:groups forKey:@"groupsTable"];
}

+(void)parseCalendarForGroupedTournamentsFromBodyNode:(HTMLNode *)bodyNode savingTo:(NSMutableDictionary *)parsingResults{
    NSMutableArray *groupsCalendar = [[NSMutableArray alloc] init];
    NSArray *groupNode = [bodyNode findChildrenOfClass:@"group span4"];
    NSString *childNodeContent;
    for (HTMLNode *group in groupNode) {
        NSMutableArray *groupMatches = [[NSMutableArray alloc] init];
        NSArray *liNodes = [[[group findChildTags:@"ul"] objectAtIndex:0] children];
        for (HTMLNode *liNode in liNodes) {
            if ([[liNode tagName] isEqualToString:@"li"]) {
                NSArray *matchesNodes = [liNode findChildTags:@"li"];
                for (HTMLNode *matchNode in matchesNodes) {
                    MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                    match.date = [[liNode findChildOfClass:@"group__match-date"] contents];
                    
                    HTMLNode *homeTeamNode = [[matchNode findChildOfClass:@"left"] findChildTag:@"strong"];
                    match.homeTeam = [homeTeamNode allContents];
                    childNodeContent = [[homeTeamNode nextSibling] allContents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    match.homeTeamCity = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    HTMLNode *guestTeamNode = [[matchNode findChildOfClass:@"right"] findChildTag:@"strong"];
                    match.guestTeam = [guestTeamNode allContents];
                    childNodeContent = [[guestTeamNode nextSibling] allContents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    match.guestTeamCity = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    
                    
                    childNodeContent = [[matchNode findChildWithAttribute:@"href" matchingName:@"match" allowPartial:YES] contents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSRange doubleDotsRange = [childNodeContent rangeOfString:@":"];
                    NSCharacterSet *digitsSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                    if ([childNodeContent rangeOfCharacterFromSet:digitsSet].location != NSNotFound) {
                        match.homeTeamScore = [[childNodeContent substringToIndex:doubleDotsRange.location] integerValue];
                        match.guestTeamScore = [[childNodeContent substringFromIndex:doubleDotsRange.location + 1] integerValue];
                    } else {
                        match.homeTeamScore = match.homeTeamScore = -1;
                    }
                    [groupMatches addObject:match];
                }
            }
        }
        [groupsCalendar addObject:groupMatches];
    }
    [parsingResults setObject:groupsCalendar forKey:@"calendar"];
}

+(NSMutableArray *)parsePlayoffsPage:(NSString *)page{
    NSMutableArray *stages = [[NSMutableArray alloc] init];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    HTMLNode *mainNode = [bodyNode findChildOfClass:@"accordion"];
    NSArray *stagesNodes = [mainNode findChildrenOfClass:@"accordion-group"];
    for (NSInteger i = 3; i < stagesNodes.count; i++) {
        NSString *stageName = [[stagesNodes[i] findChildOfClass:@"accordion-heading"] allContents];
        stageName = [ParseSiteContent deleteSpecialCharactersFromString:stageName];
        NSMutableArray *matchesInStage = [[NSMutableArray alloc] init];
        NSArray *pairs = [stagesNodes[i] findChildrenOfClass:@"main"];
        for (HTMLNode *pair in pairs) {
            NSArray *matchNodes = [pair children];
            NSMutableArray *matchesInPair = [[NSMutableArray alloc] init];
            if (matchNodes.count > 3) {
                [matchesInPair addObject:[ParseSiteContent parsePlayoffsMatchNode:matchNodes[1] forStage:stageName]];
                [matchesInPair addObject:[ParseSiteContent parsePlayoffsMatchNode:matchNodes[3] forStage:stageName]];
                [matchesInStage addObject:matchesInPair];
            }
            
        }
        [stages addObject:matchesInStage];
    }
    stages = [ParseSiteContent reversedArray:stages];
    return stages;
}

+(MatchScoreInfo *)parsePlayoffsMatchNode:(HTMLNode *)matchNode forStage:(NSString *)stage{
    PlayoffsMatchScoreInfo *match = [[PlayoffsMatchScoreInfo alloc] init];
    match.tournament = stage;
    NSArray *divNodes = [matchNode findChildTags:@"div"];
    NSString *temp = [[divNodes[0] findChildTag:@"strong"] allContents];
    match.homeTeam = [ParseSiteContent deleteSpecialCharactersFromString:temp];
    HTMLNode *goalNode = [divNodes[0] findChildOfClass:@"goals"];
    match.homeTeamScorers = [ParseSiteContent getGoalsFromNode:goalNode];
    temp = [[divNodes[2] findChildTag:@"strong"] allContents];
    match.guestTeam = [ParseSiteContent deleteSpecialCharactersFromString:temp];
    goalNode = [divNodes[2] findChildOfClass:@"goals"];
    match.guestTeamScorers = [ParseSiteContent getGoalsFromNode:goalNode];
    temp = [[divNodes[1] findChildTag:@"a"] contents];
    temp = [ParseSiteContent deleteSpecialCharactersFromString:temp];
    NSRange dashRange = [temp rangeOfString:@"–"];
    if (dashRange.location == NSNotFound) {
        NSRange doubleDotsRange = [temp rangeOfString:@":"];
        match.homeTeamScore = [[temp substringWithRange:NSMakeRange(doubleDotsRange.location - 2, 1)] integerValue];
        match.guestTeamScore = [[temp substringWithRange:NSMakeRange(doubleDotsRange.location + 2, 1)] integerValue];
    } else {
        match.homeTeamScore = -1;
        match.guestTeamScore = -1;
    }
    NSArray *liNodes = [divNodes[1] findChildTags:@"li"];
    HTMLNode *penaltyNode = [divNodes[1] findChildOfClass:@"penalty"];
    if (penaltyNode) {
        match.penalty = [[penaltyNode contents] substringFromIndex:10];
        temp = [liNodes[1] allContents];
    } else {
        temp = [liNodes[0] allContents];
    }
    NSRange dotRange = [temp rangeOfString:@"."];
    NSString *date = [temp substringToIndex:dotRange.location - 10];
    NSString *time = [temp substringWithRange:NSMakeRange(dotRange.location - 5, 5)];
    match.date = [NSString stringWithFormat:@"%@ %@", date, time];
    return match;
}

+(NSString *)deleteSpecialCharactersFromString:(NSString *)string{
    NSString *clearedString = string.copy;
    clearedString = [clearedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    clearedString = [clearedString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    clearedString = [clearedString stringByReplacingOccurrencesOfString:@"  " withString:@""];
    return clearedString;
}

+(NSMutableArray *)getGoalsFromNode:(HTMLNode *)node{
    NSMutableArray *goals;
    if (node) {
        NSArray *liNodes = [node findChildTags:@"li"];
        goals = [[NSMutableArray alloc] init];
        for (HTMLNode *li in liNodes) {
            [goals addObject:[li allContents]];
        }
    }
    return goals;
}

+ (NSMutableArray *)reversedArray:(NSMutableArray *)arrayToSort {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[arrayToSort count]];
    NSEnumerator *enumerator = [arrayToSort reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
@end
