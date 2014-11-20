//
//  ParseDynamoKievUa.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ParseDynamoKievUa.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "ArticleContent.h"
#import "TeamResults.h"
#import "PlayerStats.h"


@implementation ParseDynamoKievUa

+ (NSMutableArray *)parseDynamoNewslinePage:(NSString *)page{
    //local page
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dynamo_articles" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                         encoding:NSUTF8StringEncoding
                                            error:&errorReading];
    }
    //-local page
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    HTMLNode *bodyNode = [parser body];
    HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
    NSMutableArray *postsBetweenLiTags = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    NSString *childNodeContent = [[NSString alloc] init];
    for (HTMLNode *liNode in postsBetweenLiTags) {
        if ([liNode findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
            NSMutableArray *children = [NSMutableArray arrayWithArray:[liNode children]];
            ArticleContent *article = [[ArticleContent alloc] init];
            for (NSInteger i = children.count-1; i >= 0; i--){
                if ([[children[i] tagName] isEqualToString:@"text"]) {
                    [children removeObjectAtIndex:i];
                }
            }
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
                HTMLNode *divContent = [[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent];
                if (divContent) {
                    NSArray *pNodes = [divContent findChildTags:@"p"];
                    NSMutableString *articleContent = [[NSMutableString alloc] init];
                    for (HTMLNode *pNode in pNodes) {
                        if (![[pNode allContents] hasPrefix:@"Читать"]) {
                            [articleContent appendString:[pNode allContents]];
                            [articleContent appendString:@"\n"];
                        }
                    }
                    article.content = articleContent;
                }
            }
            article.isLoaded = NO;
            [articles addObject:article];
        }
    }
    return articles;
}

+ (ArticleContent *)fullParseDynamoArticlePage:(NSString *)page{

    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    HTMLNode *bodyNode = [parser body];
    HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
    NSArray *articleContent = [divIdPosts children];
    ArticleContent *article = [[ArticleContent alloc] init];
    NSString *childNodeContent = [[NSString alloc] init];
    for (HTMLNode *node in articleContent) {
        childNodeContent = [[node findChildTag:@"h1"] contents];
        if (childNodeContent) {
            article.title = childNodeContent;
        }
        HTMLNode *imgNode = [node findChildWithAttribute:@"itemprop" matchingName:@"image" allowPartial:NO];
        childNodeContent = [imgNode getAttributeNamed:@"src"];
        if (childNodeContent) {
            article.mainImageLink = childNodeContent;
        }
        childNodeContent = [imgNode getAttributeNamed:@"alt"];
        if (childNodeContent) {
            article.title = childNodeContent;
        }
        childNodeContent = [[node findChildWithAttribute:@"itemprop" matchingName:@"url" allowPartial:NO] contents];
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
        childNodeContent = [[node findChildWithAttribute:@"itemprop" matchingName:@"dateCreated" allowPartial:NO] contents];
        if (childNodeContent) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
            article.publishedDate = pubDate;
        }
        HTMLNode *sourceInfoNode = [node findChildOfClass:@"source"];
        HTMLNode *aNode = [sourceInfoNode findChildTag:@"a"];
        if (aNode) {
            NSString *sourceInfoURL = [aNode getAttributeNamed:@"href"];
            childNodeContent = [aNode contents];
            article.infoSource = childNodeContent;
            article.infoSourceURL = sourceInfoURL;
            HTMLNode *contentNode = [sourceInfoNode parent];
            NSArray *pNodes = [contentNode findChildTags:@"p"];
            NSMutableString *articleContent = [[NSMutableString alloc] init];
            for (HTMLNode *pNode in pNodes) {
                [articleContent appendString:[pNode allContents]];
                [articleContent appendString:@"\n"];
                article.content = articleContent;
            }
        }
    }
    return article;
}

+(void)parseDynamoArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    } else{
        HTMLNode *bodyNode = [parser body];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSArray *articleContent = [divIdPosts children];
        NSString *childNodeContent = [[NSString alloc] init];
        
        for (HTMLNode *node in articleContent) {
            HTMLNode *sourceInfoNode = [node findChildOfClass:@"source"];
            HTMLNode *aNode = [sourceInfoNode findChildTag:@"a"];
            if (aNode) {
                NSString *sourceInfoURL = [aNode getAttributeNamed:@"href"];
                childNodeContent = [aNode contents];
                article.infoSource = childNodeContent;
                article.infoSourceURL = sourceInfoURL;
            }
            HTMLNode *contentNode = [[[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent] parent];
            if (contentNode) {
                NSArray *pNodes = [contentNode findChildTags:@"p"];
                NSMutableString *articleContent = [[NSMutableString alloc] init];
                for (NSUInteger i = 0; i < pNodes.count; i++) {
                    if (i == 0) {
                        article.summary = [pNodes[i] allContents];
                    }else{
                        [articleContent appendString:[pNodes[i] allContents]];
                        [articleContent appendString:@"\n"];
                    }
                }
                article.content = articleContent;
                NSLog(@"");
            }
            childNodeContent = [[divIdPosts findChildWithAttribute:@"class"
                                                      matchingName:@"content"
                                                      allowPartial:NO] rawContents];
            if (childNodeContent) {
                NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *filename = [docsFolder stringByAppendingPathComponent:@"htmlContent.html"];
                NSError *error;
                [childNodeContent writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&error];
                NSURL *fileURL = [NSURL fileURLWithPath:filename];
                article.attributedContent = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
                
            }
        }
        article.isLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
    }
}

+ (void)parseBlogArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    } else{
        HTMLNode *bodyNode = [parser body];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"class" matchingName:@"single" allowPartial:NO];
        NSString *childNodeContent = [[NSString alloc] init];
        childNodeContent = [[divIdPosts findChildWithAttribute:@"class" matchingName:@"content" allowPartial:NO] rawContents];
        if (childNodeContent) {
            NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *filename = [docsFolder stringByAppendingPathComponent:@"htmlContent.html"];
            NSError *error;
            [childNodeContent writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&error];
            
            NSURL *fileURL = [NSURL fileURLWithPath:filename];
            article.attributedContent = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        }
        article.isLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
    }
}

+ (NSMutableArray *)parseBlogsPage:(NSString *)page{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    } else{
        NSMutableArray *articles = [[NSMutableArray alloc] init];
        HTMLNode *bodyNode = [parser body];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSMutableArray *posts = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
        NSString *childNodeContent = [[NSString alloc] init];
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
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@"comments" allowPartial:NO] getAttributeNamed:@"href"];
            if (childNodeContent) {
                NSRange idRange = NSMakeRange(childNodeContent.length - 20, 6);
                article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
            }
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
        return articles;
    }
    
}

+ (NSMutableArray *)parseMatchCenterFile:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return nil;
    } else {
        HTMLNode *body = [parser body];
        NSArray *tournaments = [body findChildrenWithAttribute:@"class" matchingName:@"match-center__group active" allowPartial:NO];
        if (tournaments.count == 0) {
            return nil;
        } else {
            NSMutableArray *content = [[NSMutableArray alloc] init];
            NSString *childNodeContent;
            for (HTMLNode *tournamentNode in tournaments) {
                NSMutableArray *tournament = [[NSMutableArray alloc] init];
                NSArray *matches = [tournamentNode findChildTags:@"tr"];
                childNodeContent = [[tournamentNode findChildWithAttribute:@"class" matchingName:@"match-center__head" allowPartial:NO] contents];
                childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                for (HTMLNode *matchNode in matches) {
                    MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                    match.tournament = childNodeContent;
                    HTMLNode *leftTeam = [matchNode findChildWithAttribute:@"class" matchingName:@"left-team" allowPartial:NO];
                    NSArray *content = [leftTeam findChildTags:@"a"];
                    match.homeTeam = [(HTMLNode *)[content lastObject] contents];
                    match.guestTeam = [[matchNode findChildWithAttribute:@"class" matchingName:@"right-team" allowPartial:NO] allContents];
                    childNodeContent = [[matchNode findChildWithAttribute:@"class" matchingName:@"scoring" allowPartial:NO] allContents];
                    
                    if([childNodeContent rangeOfString:@"-"].location == NSNotFound){
                        childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSRange dashLocation = [childNodeContent rangeOfString:@":"];
                        match.guestTeamScore = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
                        match.homeTeamScore = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
                    } else {
                        match.guestTeamScore = -1;
                        match.homeTeamScore = -1;
                    }
                    match.date = [[matchNode findChildWithAttribute:@"class" matchingName:@"date-cell" allowPartial:NO] allContents];
                    [tournament addObject:match];
                }
                [content addObject:tournament];
            }
            return content;
        }
    }
}

+(NSMutableArray *)parseLegueTablePage:(NSString *)page{
    NSMutableArray *teams = [[NSMutableArray alloc] init];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return nil;
    } else {
        HTMLNode *body = [parser body];
        NSArray *tours = [[body findChildOfClass:@"rightcol span4"] findChildrenOfClass:@"tour"];
        HTMLNode *lastPlayedTourNode = tours[0];
        NSString *pNodeContents = [[lastPlayedTourNode findChildTag:@"p"] allContents];
        NSRange openBracketRange = [pNodeContents rangeOfString:@"("];
        NSRange dashRange = [pNodeContents rangeOfString:@"-"];
        NSString *lastPlayedTourStr = [pNodeContents substringWithRange:NSMakeRange(openBracketRange.location + 1, dashRange.location - openBracketRange.location - 1)];
        NSNumber *lastPlayedTour = [[NSNumber alloc] initWithInteger:[lastPlayedTourStr integerValue]];
        HTMLNode *tbodyNode = [body findChildTag:@"tbody"];
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
    NSMutableArray *tours = [[NSMutableArray alloc] init];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return nil;
    } else {
        HTMLNode *body = [parser body];
        NSArray *tourPlayedNodes = [body findChildrenWithAttribute:@"class" matchingName:@"tour played wide_span4 span4" allowPartial:NO];
        NSMutableArray *tourNodes = [NSMutableArray arrayWithArray:tourPlayedNodes];
        NSArray *tourNotPlayedNodes = [body findChildrenWithAttribute:@"class" matchingName:@"tour  wide_span4 span4" allowPartial:NO];
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
    NSMutableArray *players = [[NSMutableArray alloc] init];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return nil;
    } else {
        HTMLNode *tbody = [[parser body] findChildTag:@"tbody"];
        NSArray *trNodes = [tbody findChildTags:@"tr"];
        for (HTMLNode *node in trNodes) {
            PlayerStats *player = [[PlayerStats alloc] init];
            NSArray *tdNodes = [node findChildTags:@"td"];
            player.nameAndTeam = [tdNodes[1] allContents];
            player.goalsScored = [[tdNodes[2] contents] integerValue];
            player.homeGoals = [[tdNodes[3] contents] integerValue];
            player.awayGoals = [[tdNodes[4] contents] integerValue];
            player.penaltyScored = [[tdNodes[5] contents] integerValue];
            [players addObject:player];
        }
    }
    return players;
}

+(MatchScoreInfo *)parseCentralMatchPage:(NSString *)page{
    MatchScoreInfo *centralMatch;
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
    } else {
        HTMLNode *bMatch = [[parser body] findChildOfClass:@"block-border"];
        if(bMatch){
            centralMatch = [[MatchScoreInfo alloc] init];
            centralMatch.tournament = [[bMatch findChildOfClass:@"b-match__head"] contents];
            NSArray *teamNameNodes = [bMatch findChildrenOfClass:@"b-match__body__name"];
            centralMatch.homeTeam = [teamNameNodes[0] contents];
            centralMatch.guestTeam = [teamNameNodes[1] contents];
            NSArray *teamCityNodes = [bMatch findChildrenOfClass:@"b-match__body__city"];
            centralMatch.homeTeamCity = [teamCityNodes[0] contents];
            centralMatch.guestTeamCity = [teamCityNodes[1] contents];
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
                    centralMatch.homeTeamScorers = [ParseDynamoKievUa nameOfScorersToArray:matchScore];
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
                    centralMatch.guestTeamScorers = [ParseDynamoKievUa nameOfScorersToArray:matchScore];
                }
            } else {
                centralMatch.homeTeamScore = centralMatch.guestTeamScore = -1;
            }
        }
    }
    return centralMatch;
}

+(NSMutableDictionary *)parseTableAndCalendarPage:(NSString *)page{
    NSMutableDictionary *parsingResult = [[NSMutableDictionary alloc] init];
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Лига чемпионов" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                         encoding:NSUTF8StringEncoding
                                            error:&errorReading];
    }
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return nil;
    } else {
        HTMLNode *bodyNode = [parser body];
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
                if (childNodeContent) {
                    team.name = childNodeContent;
                }
                childNodeContent = [[tdNodes[0] findChildTag:@"span"] allContents];
                if (childNodeContent) {
                    if ([childNodeContent hasPrefix:@" "]) {
                        childNodeContent = [childNodeContent substringFromIndex:1];
                    }
                    NSRange spaceLocation = [childNodeContent rangeOfString:@" "];
                    team.city = [childNodeContent substringFromIndex:spaceLocation.location+1];
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
        [parsingResult setObject:groups forKey:@"groupsTable"];
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
        [parsingResult setObject:groupsCalendar forKey:@"calendar"];
    }
    return parsingResult;
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

@end
