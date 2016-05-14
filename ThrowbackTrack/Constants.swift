//
//  Constants.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/7/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

struct Constants {
    
    struct CallbackConstants {  //used to test for authenticity of received URL
        static let Scheme = Config.CallbackConstants.Scheme
        static let Host = Config.CallbackConstants.Host
    }
    
    //https://developer.spotify.com/web-api/authorization-guide/
    
    struct AuthorizationConstants {
        static let Scheme = "https"
        static let Host = "accounts.spotify.com"
        static let Path = "/authorize"
        
        struct AuthParameters {
            static let ClientId = "client_id"
            static let ResponseType = "response_type"
            static let RedirectURI = "redirect_uri"
            static let Scope = "scope"
            static let State = "state"
        }
        
        struct AuthValues {
            static let ClientId = Config.AuthorizationConstants.AuthValues.ClientId
            static let ResponseType = "code"
            static let RedirectURI = Config.AuthorizationConstants.AuthValues.RedirectURI
            static let Scope = "playlist-read-private playlist-modify-public playlist-modify-private" //UPDATE TO REAL ONES!!!!
        //    static let Scope = "playlist-read-private playlist-modify-public playlist-modify-private streaming"  //TESTING VERSION since spotify does not currently support revoking 3d party apps, so it was necessary to test in other ways
        }
    }
    
    struct AccessTokenConstants {
        static let PostURL = "https://accounts.spotify.com/api/token"
        
        struct AuthParameters {
            static let GrantType = "grant_type"
            static let Code = "code"
            static let RedirectURI = "redirect_uri"
            static let ClientId = "client_id"
            static let ClientSecret = "client_secret"
        }
        
        struct AuthValues {
            static let GrantType = "authorization_code"
            static let RedirectURI = Config.AccessTokenConstants.AuthValues.RedirectURI
            static let ClientId = Config.AccessTokenConstants.AuthValues.ClientId
            static let ClientSecret = Config.AccessTokenConstants.AuthValues.ClientSecret
        }
    }
    
    struct RefreshTokenConstants {
        static let PostURL = "https://accounts.spotify.com/api/token"
        
        struct AuthParameters {
            static let GrantType = "grant_type"
            static let RefreshToken = "refresh_token"
            static let ClientId = "client_id"
            static let ClientSecret = "client_secret"
        }
        
        struct AuthValues {
            static let GrantType = "refresh_token"
            static let ClientId = Config.RefreshTokenConstants.AuthValues.ClientId
            static let ClientSecret = Config.RefreshTokenConstants.AuthValues.ClientSecret
        }
    }
    
    //https://developer.spotify.com/web-api/endpoint-reference/
    
    struct DataClientConstants {
        
        static let Scheme = "https"
        static let Host = "api.spotify.com"
        
        struct Search {
            static let Path = "/v1/search"
            
            
            
        }
        
        struct Playlists {
            static let GetTracksPath = "/v1/users"
            static let GetUserPlaylistsPath = "/v1/me"
            
            
            
        }
    }
    
    struct LoginViewConstants {
        static let DismissSafariWindowNotification = "dismissSafariWindowAfterAuthReceived"
    }
}