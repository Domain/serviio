var host = window.location.host;

var baseFolderId = 0;
var folderListUrl = "http://"
		+ host
		+ "/cds/browse/flv_player/{folderId}/BrowseDirectChildren/containers/0/0?authToken={token}";
var folderItemsUrl = "http://"
		+ host
		+ "/cds/browse/flv_player/{folderId}/BrowseDirectChildren/items/{offset}/{limit}?authToken={token}";
var itemMetadataUrl = "http://"
		+ host
		+ "/cds/browse/flv_player/{objectId}/BrowseMetadata/all/0/1?authToken={token}";

var loginUrl = "http://" + host + "/cds/login";
var logoutUrl = "http://" + host + "/cds/logout";

// error codes
var httpErrorCodeMap = {
	"401" : "There was a problem in the authentication process, check your password and try again",
	"404" : "Unable to find the requested resource"
}

var errorCodeMap = {
	"554" : "This functionality is only available for Serviio Pro. Your license might have expired.",
	"556" : "You did not create a password for the web user. Enter it in the Serviio console.",
	"557" : "The streaming server has not started yet or has been stopped."
}

// error messages
var messageMap = {
	"nologin" : "Unable to login, please check your password and try again",
	"defaulterror" : "Sorry, a problem has occurred"
}

var PLAYLIST_COOKIE_NAME = "serviio-playlist-data";
var playlistImageShowInMillis = 10000;
var playlistHideoutTimeoutInMillis = 800;

var playlistShowTimer = $.timer(function() {
	hidePlaylist();
	playlistShowTimer.stop();
});

playlistShowTimer.set({
	time : playlistHideoutTimeoutInMillis
});
playlistShowTimer.pause();

var playlistImageTimer = $.timer(function() {
	playlistImageTimer.stop();
	$(".piro_close").click();
	$(".piro_html, .piro_overlay").remove();
	playNextInPlaylist();
});

var playListObjects = {};

var thumbElementWidth = 169;
var thumbElementHeight = 210;
var folderGridSpace = 11;
var minGridRows = 1;

var breadcrumb = [];
var folderNames = {};

var idHash = {};
var idReverseHash = {};
var idCounter = 0;

function showErrorMessage(httpCode, errorCode) {
	if (errorCode && errorCodeMap[errorCode]) {
		showMessage(errorCodeMap[errorCode]);
	} else if (httpErrorCodeMap[httpCode]) {
		showMessage(httpErrorCodeMap[httpCode]);
	} else {
		showMessage(messageMap["defaulterror"] + " (" + errorCode ? errorCode
				: httpCode + ")");
	}
}

function isResponseOK(data) {
	if (data.httpCode && (data.httpCode != 200)) {
		showErrorMessage(data.httpCode, data.errorCode);
		return false
	}
	return true
}

function shortenString(string, limit) {
	if (!string) {
		return '';
	} else if (string.length <= limit) {
		return string;
	} else {
		return '<span class="tooltip" data-tooltip="' + string + '">'
				+ string.substring(0, limit) + '..</span>';
	}
}

function wrapWithTooltipPlaylist(string) {
	if (!string) {
		return '';
	} else {
		return '<span class="playlistTooltip textShortening" data-tooltip="'
				+ string + '">' + string + '</span>';
	}
}

function wrapWithTooltip(string) {
	if (!string) {
		return '';
	} else {
		return '<span class="tooltip textShortening" data-tooltip="' + string
				+ '">' + string + '</span>';
	}
}

function buildSecuredUrl(url) {
	if (url) {
		return "http://" + host + url + "?authToken=" + sec_token;
	}
	return null;
}

function sanitizeId(id) {

	var newId = idReverseHash[id];
	if (newId == null) {
		newId = idCounter;
		idCounter++;

		idHash[newId] = id;
		idReverseHash[id] = newId;
	}
	return newId;
}

function unsanitizeId(id) {
	return idHash[id];
}

function createBreadcrumbElement(folderId, folderName) {
	return '<li><div id="breadcrumb_' + folderId + '" class="breadcrumb">'
			+ shortenString(folderName, 10) + '</div></li>';
}

function refreshFolderList(folderId) {

	var currentFolderName = folderNames[folderId];
	updateBreadcrumb(folderId, currentFolderName);
	if (folderId != baseFolderId) {
	}

	var actionUrl = folderListUrl.replace('{folderId}', unsanitizeId(folderId))
			.replace('{token}', sec_token);

	$.ajax({
		url : actionUrl,
		dataType : 'json',
		// crossDomain: true,
		error : function(error) {
			showMessage(messageMap["defaulterror"]);
		},
		success : function(data) {
			if (!isResponseOK(data)) {
				hideMainWindow(showLoginBox);
				return;
			}
			var items = [];
			$.each(data.objects, function(key, object) {
				if (object.type == 'CONTAINER') {
					var liElement = '<li><div id="' + sanitizeId(object.id)
							+ '" class="folderLink">'
							+ wrapWithTooltip(object.title) + '</div></li>';
					items.push(liElement);
					folderNames[sanitizeId(object.id)] = object.title;
				}
			});

			$('#folderNav ul').html(items.join(''));

			// add onclick events to the newly added folder and breadcrumb
			// elements:
			$('.folderLink').unbind('click');
			$('.folderLink').click(function() {
				refreshFolderList(this.id);
			})

			$('.breadcrumb').unbind('click');
			$('.breadcrumb').click(function() {
				refreshFolderList(this.id.replace('breadcrumb_', ''));
			})
			$('#breadcrumb_' + folderId).unbind('click');
			$('.active').removeClass('active');
			$('#breadcrumb_' + folderId).addClass('active');

			hideGridMessages();
			if (items.join('') == '') {
				$('.ui-tooltip').hide();
				hideFolderNav(folderId);
			} else {
				showFolderNav(folderId);
				initTooltips();
			}
		}
	});

}

function initTooltips() {
	$('.tooltip').qtip({
		content : {
			attr : 'data-tooltip'
		},
		style : {
			classes : 'ui-tooltip-dark ui-tooltip-rounded ui-tooltip-tipsy'
		},
		position : {
			my : 'top left',
			at : 'center'
		}
	});
}

function updateBreadcrumb(folderId, folderName) {
	var folderAlreadyInBreadcrumb = false;
	$.each(breadcrumb, function(key, obj) {
		var currentFolderId;
		for (propname in obj) {
			currentFolderId = propname;
		}
		if (folderAlreadyInBreadcrumb) {
			$('#breadcrumb_' + currentFolderId).parent().remove();
			delete breadcrumb[key];
		} else if (currentFolderId == folderId) {
			folderAlreadyInBreadcrumb = true;
		}
	});

	if (!folderAlreadyInBreadcrumb) {
		var obj = {};
		obj[folderId] = createBreadcrumbElement(folderId, folderName);
		breadcrumb.push(obj);
		$('#breadcrumbContainer ul').append(obj[folderId]);
	}
	initTooltips();
}

var navWidth = $('#folderNav:visible').width();
var navHorizontalPos = $('#folderNav:visible').css('left');

var gridHorizontalPos = 0

function showFolderNav(folderId) {
	gridHorizontalPos = 0;

	hideGrid('right', function() {
		if ($('#folderNav').is(':hidden')) {
			$('#folderNav').css('display', 'block');
			$('#folderNav').animate(
					{
						left : navHorizontalPos
					},
					500,
					"swing",
					function() {
						$('#thumbsGrid').css('width',
								$('#thumbsGrid').width() - navWidth);
						$('#thumbsGridViewPort').css(
								'width',
								$('#thumbsGridViewPort').width() - navWidth
										- folderGridSpace);
						$('#thumbsGridViewPort').css(
								'left',
								parseInt($('#thumbsGridViewPort').css('left'))
										+ navWidth + folderGridSpace);
						loadMetaDataForFolder(folderId, 0);
						showGrid();
					});
		} else {
			loadMetaDataForFolder(folderId, 0);
			showGrid();
		}
	});

}

function hideFolderNav(folderId) {
	gridHorizontalPos = 0;

	hideGrid('right', function() {
		if ($('#folderNav').is(':visible')) {
			navHorizontalPos = $('#folderNav').css('left');
			$('#folderNav').animate(
					{
						left : -200
					},
					400,
					"swing",
					function() {
						$('#folderNav').css('display', 'none');
						$('#thumbsGrid').css('width',
								$('#thumbsGrid').width() + navWidth);
						$('#thumbsGridViewPort').css(
								'width',
								$('#thumbsGridViewPort').width() + navWidth
										+ folderGridSpace);
						$('#thumbsGridViewPort').css(
								'left',
								parseInt($('#thumbsGridViewPort').css('left'))
										- navWidth - folderGridSpace);
						loadMetaDataForFolder(folderId, 0);
						showGrid();
					});
		} else {
			loadMetaDataForFolder(folderId, 0);
			showGrid();
		}
	});
}

function showGrid() {
	if ($('#thumbsGrid').is(':hidden')) {

		$('#thumbsGrid').css('display', 'block');
		$('#thumbsGrid').animate({
			left : gridHorizontalPos
		}, 700, "swing", function() {

		});
	}
}

function hideGrid(direction, callbackFn) {
	var pos = 0 - $('#thumbsGrid').width() - 10;
	if (direction == 'right') {
		pos = $('#thumbsGrid').width() + 10;
	}
	if ($('#thumbsGrid').is(':visible')) {
		$('#thumbsGrid').css('overflow-y', 'hidden');
		$('#thumbsGrid').animate({
			left : pos
		}, 700, "swing", function() {
			$('#thumbsGrid').css('display', 'none');
			if (callbackFn) {
				callbackFn();
			}
		});
	}

}

function calculateCurrentThumbViewLimit() {

	var thumbsGrid = $('#thumbsGrid');

	var rows = parseInt(thumbsGrid.height() / thumbElementHeight);
	var columns = parseInt(thumbsGrid.width() / thumbElementWidth);

	if (columns < 1) {
		columns = 1;
	}
	if (rows < minGridRows) {
		rows = minGridRows;
	}

	var numberOfWholeElements = rows * columns;
	return numberOfWholeElements;
}

var visibleMediaObjects = {};
var totalNumberOfItemsForCurrentFolder = 0;
var currentFolderId = 0;
var currentPage = 0;
function loadMetaDataForFolder(folderId, pageNumber) {

	var viewLimit = calculateCurrentThumbViewLimit();
	var objectsOffset = parseInt(pageNumber) * parseInt(viewLimit);

	var callUrl = folderItemsUrl.replace('{folderId}', unsanitizeId(folderId))
			.replace('{limit}', viewLimit).replace('{offset}',
					objectsOffset + "").replace('{token}', sec_token);

	$('#thumbsGrid').empty();

	visibleMediaObjects = {};

	$
			.ajax({
				url : callUrl,
				dataType : 'json',
				// crossDomain: true, doesn't work in IE
				error : function(error) {
					showMessage(messageMap["defaulterror"]);
				},
				success : function(data) {
					if (!isResponseOK(data)) {
						hideMainWindow(showLoginBox);
						return;
					}
					totalNumberOfItemsForCurrentFolder = data.totalMatched;
					currentFolderId = folderId;
					currentPage = pageNumber;

					var items = [];
					var imagesPresent = false;
					$
							.each(
									data.objects,
									function(key, object) {
										var thumbSource = getThumbnailUrl(object)

										var uniqueId = sanitizeId(object.id);

										var element = "";
										if (object.fileType == "IMAGE") {
											imagesPresent = true;
											var contentUrl = buildSecuredUrl(getOriginalQualityContent(object).url);
											element = '<div id="' + uniqueId
													+ '" class="thumbPanel">';

											element += "<div class='item-overlay' id='"
													+ uniqueId
													+ "-play-overlay' style='cursor:pointer; display:none; margin-left:0px; margin-top:0px;  width:44px; height:44px; "
													+ "z-index:1000; position:absolute;'"
													+ "><div id='"
													+ uniqueId
													+ "-play-button' >"
													+ '<a style="background-color:transparent" href="'
													+ contentUrl
													+ '" rel="single" class="pirobox imageWrapper" title="'
													+ object.title
													+ '">'
													+ "<img src='images/play_icon_large.png' width='44px' height='44px'/></a></div></div>";

											element += '<div class="imageWrapper">';

											element += '<img src="'
													+ thumbSource
													+ '" style="position: absolute;" onload="OnImageLoad(event);" /></div><div class="itemTitle">'
													+ wrapWithTooltip(object.title)
													+ '</div>';
											if (getOriginalQualityContent(object).resolution) {
												element += '<div class="itemDuration">'
														+ getOriginalQualityContent(object).resolution
														+ '</div>';
											}
											element += '</div>';
										} else {
											element = '<div id="'
													+ uniqueId
													+ '" class="thumbPanel"><div class="imageWrapper"><img  src="'
													+ thumbSource
													+ '" style="position: absolute;" onload="OnImageLoad(event);"/></div>';

											element += "<div class='item-overlay' id='"
													+ uniqueId
													+ "-play-overlay' style='cursor:pointer; display:none; margin-left:0px; margin-top:0px;  width:44px; height:44px; "
													+ "z-index:1000; position:absolute;'"
													+ "><div id='"
													+ uniqueId
													+ "-play-button' onclick=\"playFolderContinuously('"
													+ object.id
													+ "');"
													+ "\" ><img src='images/play_icon_large.png' width='44px' height='44px'/></div></div>";

											element += '<div class="itemTitle">'
													+ wrapWithTooltip(object.title)
													+ '</div>';
											if (object.duration) {
												element += '<div class="itemDuration">'
														+ formatSecondsAsTime(
																parseInt(object.duration),
																'hh:mm:ss')
														+ '</div>';
											}
											element += '</div>';
										}

										items.push(element);

										visibleMediaObjects[object.id] = object;
									});
					$('#thumbsGrid').html(items.join(''));
					initTooltips();
					if (imagesPresent) {
						initPiroBox();
					}

					if ((items.length == 0) && (folderId != baseFolderId)) {
						hideWelcomeMessage();
						showNoContentMessage();
					} else if (folderId == baseFolderId) {
						hideNoContentMessage();
						showWelcomeMessage();
					} else {
						hideGridMessages();
					}

					// add onclick events to the newly added elements:

					$('.thumbPanel').unbind('dblclick');
					$('.thumbPanel').dblclick(function() {
						showMedia(unsanitizeId(this.id));
					});
					$('.thumbPanel image').unbind('click');

					$('.thumbPanel').draggable(
							{
								revert : "invalid",
								helper : "clone",
								appendTo : "body",
								cursor : "move",
								containment : "#mainContainer",
								start : function() {

									$('.item-overlay-playlist').css('display',
											'none');

									$(".item-overlay").css('display', 'none');

									$('#playlistDiv, #playlistScrollBox')
											.filter(":animated").stop();

									showPlaylist();
									playlistShowTimer.set({
										time : playlistHideoutTimeoutInMillis
									});
									playlistShowTimer.pause();
								},
								drag : function() {
									$(".item-overlay").css('display', 'none');
									$('.item-overlay-playlist').css('display',
											'none');
									playlistShowTimer.set({
										time : playlistHideoutTimeoutInMillis
									});
									playlistShowTimer.pause();

								},
								stop : function() {
									$(".item-overlay").css('display', 'none');
									playlistShowTimer.set({
										time : playlistHideoutTimeoutInMillis
									});
									playlistShowTimer.play();

									$('.item-overlay-playlist').removeClass(
											'fired');
								},
							});

					$('.thumbPanel').mouseover(
							function(event) {
								var id = event.currentTarget.id;
								var offset = $('#' + id).offset();

								var navOffset = 0;
								if ($('#folderNav').is(':visible')) {
									navOffset = navWidth + 10;
								}

								$("#" + id + "-play-overlay").css('top',
										offset.top - 85);
								$("#" + id + "-play-overlay").css('left',
										offset.left + 30 - navOffset);
								$("#" + id + "-play-overlay").css('display',
										'block');
							});

					$('.thumbPanel').mouseout(function(event) {
						var id = event.currentTarget.id;
						$("#" + id + "-play-overlay").css('display', 'none');
					});

					// $( '.thumbPanel' ).sortable();
					// $( '.thumbPanel' ).disableSelection();

					refreshPaginationElements();
				}
			});
}

function getOriginalQualityContent(object) {
	return getQualityContent(object, 'ORIGINAL');
}

function getDefaultQualityType(object) {
	var i;
	for (i in object.contentUrls) {
		if (object.contentUrls[i].preferred == true) {
			return object.contentUrls[i].quality;
		}
	}
}

function getQualityContent(object, quality) {
	var i;
	for (i in object.contentUrls) {
		if (object.contentUrls[i].quality == quality) {
			return object.contentUrls[i];
		}
	}
}

function hideGridMessages() {
	hideNoContentMessage();
	hideWelcomeMessage();
}

function getThumbnailUrl(object) {
	var thumbSource = "";
	if (object.thumbnailUrl) {
		thumbSource = buildSecuredUrl(object.thumbnailUrl);
	} else {
		if (object.fileType == "AUDIO") {
			thumbSource = "images/audio_placeholder.jpg";
		} else if (object.fileType == "VIDEO") {
			thumbSource = "images/video_placeholder.jpg";
		} else if (object.fileType == "IMAGE") {
			thumbSource = "images/image_placeholder.jpg";
		}
	}
	return thumbSource;
}

function showNoContentMessage() {
	resizeElements();
	if ($('#noContentMessage').is(':hidden')) {
		$('#noContentMessage').show();
		$('#noContentMessage').animate({
			opacity : 0.8
		}, 500, "swing");
	}
}

function hideNoContentMessage() {
	if ($('#noContentMessage').is(':visible')) {
		$('#noContentMessage').animate({
			opacity : 0
		}, 500, "swing");
		$('#noContentMessage').hide();
	}
}

function showWelcomeMessage() {
	resizeElements();
	if ($('#welcomeMessage').is(':hidden')) {
		$('#welcomeMessage').show();
		$('#welcomeMessage').animate({
			opacity : 0.8
		}, 500, "swing");
	}
}

function hideWelcomeMessage() {
	if ($('#welcomeMessage').is(':visible')) {
		$('#welcomeMessage').animate({
			opacity : 0
		}, 500, "swing");
		$('#welcomeMessage').hide();
	}
}

function initPiroBox() {
	$.piroBox_ext({
		piro_speed : 600,
		bg_alpha : 0.9,
		piro_drag : false,
		piro_nav_pos : 'bottom',
		piro_scroll : true
	// pirobox always positioned at the center of the page
	});
}

function swipeGridLeft(folderId, page) {
	hideGrid('left', function() {
		loadMetaDataForFolder(folderId, page);
		$('#thumbsGrid').css('left', $('body').width() + 50);
		showGrid();
	});
}

function swipeGridRight(folderId, page) {
	hideGrid('right', function() {
		loadMetaDataForFolder(folderId, page);
		$('#thumbsGrid').css('left', 0 - $('#thumbsGrid').width() - 50);
		showGrid();
	});
}

function loadNextPageForCurrentFolder() {
	if (currentPage < (getTotalNumberOfPages() - 1)) {
		swipeGridLeft(currentFolderId, currentPage + 1);
	}
}

function loadPrevPageForCurrentFolder() {
	if (currentPage > 0) {
		swipeGridRight(currentFolderId, currentPage - 1);
	}
}

function getTotalNumberOfPages() {
	var currentViewLimit = calculateCurrentThumbViewLimit();
	var totalNumberOfPages = Math.ceil(totalNumberOfItemsForCurrentFolder
			/ currentViewLimit);

	return totalNumberOfPages;
}

function refreshPaginationElements() {
	var totalNumberOfPages = getTotalNumberOfPages();
	var pageLinkLimit = 7;
	var halfPageLinkLimit = pageLinkLimit / 2;

	if (isNaN(totalNumberOfPages) || (totalNumberOfPages <= 1)) {
		$('.pagination').empty();
		return;
	}

	var html = '<span class="pagination_info">page ' + (currentPage + 1)
			+ ' of ' + totalNumberOfPages
			+ '</span> <span class="pagination-prev">&lt;</span>';

	var addDotsAtTheEnd = false;
	var linkPage = 0;
	if (totalNumberOfPages > pageLinkLimit) {
		if (currentPage <= halfPageLinkLimit) {
			linkPage = 1;
			addDotsAtTheEnd = true;
		} else if (currentPage < Math.floor(totalNumberOfPages
				- halfPageLinkLimit)) {
			linkPage = 1 + Math.ceil(currentPage - halfPageLinkLimit);
			pageLinkLimit += linkPage - 1;
			html += '...';
			addDotsAtTheEnd = true;
		} else if (currentPage >= Math.floor(totalNumberOfPages
				- halfPageLinkLimit)) {
			linkPage = 1 + (totalNumberOfPages - pageLinkLimit);
			pageLinkLimit += linkPage - 1;
			html += '...';
		}
	} else {
		linkPage = 1;
		pageLinkLimit = totalNumberOfPages;
	}

	for ( var i = linkPage; i <= pageLinkLimit; i++) {
		html += '<span '
				+ (((i - 1) == currentPage) ? ' class="pagination-current" '
						: '') + '>' + i + '</span>';
	}

	if (addDotsAtTheEnd) {
		html += '...';
	}
	html += '<span class="pagination-next">&gt;</span>';

	$('.pagination').empty();
	$('.pagination').html(html);

	$('.pagination span').unbind('click');
	$('.pagination span').click(function(event) {
		var page = parseInt(event.target.innerHTML) - 1;

		if (page > currentPage) {
			swipeGridLeft(currentFolderId, page);
		} else {
			swipeGridRight(currentFolderId, page);
		}

	});
	$('.pagination span.pagination-current').unbind('click');

	$('.pagination-next').unbind('click');
	$('.pagination-next').click(function() {
		loadNextPageForCurrentFolder();
	});

	$('.pagination-prev').unbind('click');
	$('.pagination-prev').click(function() {
		loadPrevPageForCurrentFolder();
	});

}
var playListOrder = [];

function playPlaylist(objectId) {

	try {
		closeMediaPlayerWindow();
	} catch (e) {
	}
	var mediaObj = null;
	if (!folderPlayback) {

		initPlaylistOrder();

		mediaObj = playListObjects[objectId];
	} else {
		mediaObj = folderObjects[objectId];
	}

	currentlyPlayingObject = mediaObj;

	if (mediaObj.fileType == 'IMAGE') {

		var contentUrl = buildSecuredUrl(getOriginalQualityContent(mediaObj).url);
		var aTagId = sanitizeId(mediaObj.id) + "-view-image-link";
		var element = '<a id="' + aTagId + '" style="display:none" href="'
				+ contentUrl
				+ '" rel="single" class="pirobox imageWrapper" title="'
				+ mediaObj.title + '"></a>';

		$("body").append(element);
		initPiroBox();
		$("#" + aTagId).click();
		$("#" + aTagId).remove();

		playlistImageTimer.set({
			time : playlistImageShowInMillis
		});

		playlistImageTimer.play();

	} else {
		showMedia(mediaObj);
	}

}

function initPlaylistOrder() {
	playListOrder = [];
	$('#playlistUl').children('li').each(function() {
		playListOrder.push(playListIdsToObjectIdsMap[this.id]);
	});
}

var folderPlayback = false;
var folderPlayOrder = [];
var folderObjects = {}
function playFolderContinuously(objectId) {
	folderPlayback = true;

	var callUrl = folderItemsUrl.replace('{folderId}',
			unsanitizeId(currentFolderId)).replace('{limit}', "0").replace(
			'{offset}', "0").replace('{token}', sec_token);

	folderObjects = {};
	folderPlayOrder = [];

	$.ajax({
		url : callUrl,
		dataType : 'json',
		error : function(error) {
			showMessage(messageMap["defaulterror"]);
		},
		success : function(data) {
			$.each(data.objects, function(index, object) {
				folderPlayOrder.push(object.id);
				folderObjects[object.id] = object;
			});

			playPlaylist(objectId);
		}
	});

}

var currentlyPlayingObject;
function playNextInPlaylist() {
	initPlaylistOrder();

	var object = currentlyPlayingObject;

	var orderArray = playListOrder;
	var objectContainder = playListObjects;
	if (folderPlayback) {
		orderArray = folderPlayOrder;
		objectContainder = folderObjects;
	}

	for ( var i = 0; i < orderArray.length; i++) {

		if (object.id == orderArray[i]) {
			var nextObject = null;
			try {

				nextObject = objectContainder[orderArray[i + 1]];
				if (nextObject != null) {
					// var playbackWasFullscreen = playerIsFullScreen;

					if (currentlyPlayingObject.fileType != 'IMAGE') {
						closeMediaPlayerWindow();
					}

					playPlaylist(nextObject.id);

					// Fullscreen mode cannot be changed from outside the
					// player...
					// if (playbackWasFullscreen) {
					// flowplayer().toggleFullscreen();
					// }
				}
				return;
			} catch (e) {
			}

		}

	}
}

function showMedia(objectId) {

	var object = null;
	if (objectId.fileType != null) {
		object = objectId;
	} else {
		object = visibleMediaObjects[objectId];
	}

	currentlyPlayingObject = object;

	if (object.fileType == "AUDIO") {
		playAudio(object)
	} else if (object.fileType == "VIDEO") {
		showVideo(object);
	}
	initTooltips();
}

function playAudio(object) {
	if (object) {
		highlightPlayListClip(object.id);

		var width = 500;
		var height = 30; // controls height

		var topMargin = 100;
		var leftMargin = parseInt(($(window).width() - width) / 2);

		var objectId = sanitizeId(object.id);

		var closeXoffset = parseInt(width) + 25;
		var closeYoffset = -15;

		var year = '';
		if (object.date) {
			year = object.date.substring(0, 4);
		}

		var contentUrl = buildSecuredUrl(getOriginalQualityContent(object).url);

		var html = '<div class="lightbox"></div><div class="lighboxMediaFrame ui-corner-all" style="width:'
				+ width
				+ 'px; margin-top:'
				+ topMargin
				+ 'px; margin-left:'
				+ leftMargin + 'px;">';
		html += '<div style="position:absolute; z-index:220; top:'
				+ closeYoffset + 'px; left:' + closeXoffset
				+ 'px;"><img class="closer" src="images/x.png"/></div>';
		html += '<div class="ui-corner-all metadata"><h4>' + object.title
				+ '</h4>';
		html += '<table><tr>';
		html += '<td width="300"><div class="tdLabel">Artist:</div><div class="tdValue">'
				+ wrapWithTooltip(object.artist) + '</div></td>';
		html += '<td width="160" rowspan="5"><img src="'
				+ getThumbnailUrl(object) + '"/></td>';
		html += '</tr><tr>';
		html += '<td width="300"><div class="tdLabel">Album:</div><div class="tdValue">'
				+ wrapWithTooltip(object.album) + '</div></td>';
		html += '</tr><tr>';
		html += '<td width="300"><div class="tdLabel">Track:</div><div class="tdValue">'
				+ wrapWithTooltip(object.originalTrackNumber) + '</div></td>';
		html += '</tr><tr>';
		html += '<td width="300"><div class="tdLabel">Genre:</div><div class="tdValue">'
				+ wrapWithTooltip(object.genre) + '</div></td>';
		html += '</tr><tr>';
		html += '<td width="300"><div class="tdLabel">Year:</div><div class="tdValue">'
				+ wrapWithTooltip(year) + '</div></td>';
		html += '</tr></table>';
		html += '</div>';
		html += '<a id="flowplayer_aud" style="display:block;width:' + width
				+ 'px;height:' + height + 'px;"></a>';
		html += '</div>';

		$('body').append(html);

		var clip = {
			scaling : 'fit',
			accelerated : true,
			autoPlay : true,
			autoBuffering : true,
			duration : object.duration,
			live : object.live,
			url : contentUrl,
			provider : 'audio',
			onPause : function() {
				return (object.live ? this.close() : this.pause());
			},
			onResume : function() {
				return (object.live ? this.play() : this.resume());
			},
			onStart : function(clip) {
				// alert("clip started");
			},
			onFinish : function(clip) {
				// alert("clip ended");
				playNextInPlaylist();
			}

		};

		initFlowPlayer("flowplayer_aud", {
			audio : {
				url : 'swf/flowplayer.audio-3.2.8.swf'
			},
			controls : {
				fullscreen : false,
				autoHide : false,
				backgroundColor : "#000000",
				backgroundGradient : "none",
				sliderColor : '#FFFFFF',
				sliderBorder : '1.5px solid rgba(160,160,160,0.7)',
				volumeSliderColor : '#FFFFFF',
				volumeBorder : '1.5px solid rgba(160,160,160,0.7)',

				timeColor : '#ffffff',
				durationColor : '#ffffff',
				timeSeparator : ' / ',

				tooltipColor : 'rgba(255, 255, 255, 0.7)',
				tooltipTextColor : '#000000'
			}
		}, clip);

		$('.closer').unbind('click');
		$('.closer').click(function() {
			closeMediaPlayerWindow();
		});

		// $('.lightbox').unbind('click');
		// $('.lightbox').click(function(){
		// closeMediaPlayerWindow();
		// });
	}
}

var playerIsFullScreen = false;

function initFlowPlayer(containerId, pluginsObject, clip) {

	flowplayer(containerId, "swf/flowplayer-3.2.9.swf", {
		canvas : {
			// backgroundColor:'#000000', must be disabled otherwise fullscreen
			// doesnt work
			backgroundGradient : 'none'
		},
		logo : {
			fullscreenOnly : true
		},

		onFullscreen : function() {
			playerIsfullScreen = true;
		},
		onFullscreenExit : function() {
			playerIsfullScreen = false;
		},
		clip : clip,
		// playlist : playlist,
		plugins : pluginsObject
	});
}

function highlightPlayListClip(objectId) {

	$.each(playListIdsToObjectIdsMap, function(liId, objId) {
		if (objId == objectId) {
			$('.playlistItem').removeClass('highlighted');
			$('#' + liId).addClass('highlighted');
		}

	});

}

function showVideo(object) {

	if (object) {
		highlightPlayListClip(object.id);

		var videoSizeRatio = 0.5;
		var selectedQuality = getDefaultQualityType(object);
		var originalContent = getOriginalQualityContent(object);
		var width = parseInt(originalContent.resolution.split('x')[0]);
		var height = parseInt(originalContent.resolution.split('x')[1]);

		var maxPlayerWidth = parseInt($(window).width() * videoSizeRatio);
		var maxPlayerHeight = parseInt($(window).height() * videoSizeRatio);

		if (width > maxPlayerWidth) {
			height = parseInt(height * (maxPlayerWidth / width.toFixed(2)));
			width = maxPlayerWidth;
		}

		if (height > maxPlayerHeight) {
			width = parseInt(width * (maxPlayerHeight / height.toFixed(2)));
			height = maxPlayerHeight;
		}

		var leftMargin = parseInt(($(window).width() - width) / 2);

		var closeXoffset = parseInt(width) + 25;
		var closeYoffset = -15;

		var html = '<div class="lightbox" ></div><div class="lighboxMediaFrame ui-corner-all" style="width:'
				+ width
				+ 'px; display:block; margin-left:'
				+ leftMargin
				+ 'px;">';
		html += '<div style="position:absolute; z-index:220; top:'
				+ closeYoffset + 'px; left:' + closeXoffset
				+ 'px;"><img class="closer" src="images/x.png"/></div>';
		html += '<div class="ui-corner-all metadata"><h4>'
				+ wrapWithTooltip(object.title) + '</h4>';
		html += '<table><tr>';
		html += '<td width="33%"><div class="tdLabel">Date:</div><div class="tdValue">'
				+ wrapWithTooltip(object.date) + '</div></td>';
		html += '<td width="33%"><div class="tdLabel">Genre:</div><div class="tdValue">'
				+ wrapWithTooltip(object.genre) + '</div></td>';
		html += '<td width="33%"><div class="tdLabel">Resolution:</div><div class="tdValue" id="videoResolution">'
				+ wrapWithTooltip(getQualityContent(object, selectedQuality).resolution)
				+ '</div></td>';
		html += '</tr></table>';
		html += '</div>';
		html += '<a id="flowplayer_vid" style="display:block;width:' + width
				+ 'px;height:' + height + 'px;"></a>';

		if (object.description) {
			html += '<h4>Summary</h4>';
			html += '<div id="metadataSummary" class="ui-corner-all metadata"><p>'
					+ object.description + '</p></div>';
		}
		html += '</div>';

		$('body').append(html);

		if (object.description) {
			$('#metadataSummary').slimScroll({
				height : $('#metadataSummary').height(),
				color : '#aaaaaa'
			});
		}

		var topMargin = ($('body').height() - $('.lighboxMediaFrame').height()) / 2;
		$('.lighboxMediaFrame').css('margin-top', topMargin);

		var videoPlugins = {
			menu : {
				url : 'swf/flowplayer.menu-3.2.8.swf',
				items : [
				// you can have an optional label as the first item
				// the bitrate specific items are filled here based on the
				// clip's bitrates
				{
					label : "Select quality:",
					enabled : false
				} ]
			},
			brselect : {
				url : "swf/flowplayer.bitrateselect-3.2.8.swf",
				menu : true,
				onStreamSwitchBegin : function(newItem, currentItem) {
					var newSelectedQuality = newItem.label;
					// update resolution in the panel on quality switch
					$('#videoResolution').html(
							shortenString(getQualityContent(object,
									newSelectedQuality).resolution, 30));
				}
			},

			controls : {
				backgroundColor : "#000000",
				backgroundGradient : "none",
				sliderColor : '#FFFFFF',
				sliderBorder : '1.5px solid rgba(160,160,160,0.7)',
				volumeSliderColor : '#FFFFFF',
				volumeBorder : '1.5px solid rgba(160,160,160,0.7)',

				timeColor : '#ffffff',
				durationColor : '#ffffff',
				timeSeparator : ' / ',

				tooltipColor : 'rgba(255, 255, 255, 0.7)',
				tooltipTextColor : '#000000',

			// playlist : true
			},
			serviio : {
				url : "flowplayer.serviiostreaming-1.0.10.swf"
			}

		};
		if (object.subtitlesUrl) {
			videoPlugins["captions"] = {
				url : 'swf/flowplayer.captions-3.2.8.swf',
				captionTarget : 'content'
			};
			videoPlugins["content"] = {
				url : 'swf/flowplayer.content-3.2.8.swf',
				bottom : 5,
				height : 40,
				backgroundColor : 'transparent',
				backgroundGradient : 'none',
				border : 0,
				textDecoration : 'outline',
				style : {
					body : {
						fontSize : 14,
						fontFamily : 'Arial',
						textAlign : 'center',
						color : '#ffffff'
					}
				}
			};
		}

		var bitratesArray = [];
		for ( var i = 0; i < object.contentUrls.length; i++) {
			bitratesArray.push({
				url : buildSecuredUrl(object.contentUrls[i].url),
				width : 480,
				bitrate : (i + 1) * 100,
				isDefault : object.contentUrls[i].quality == selectedQuality,
				label : object.contentUrls[i].quality
			});
		}

		var clip = {
			scaling : 'fit',
			accelerated : true,
			autoPlay : true,
			autoBuffering : true,
			duration : object.duration,
			live : object.live,
			captionUrl : buildSecuredUrl(object.subtitlesUrl),
			bitrates : bitratesArray,
			provider : 'serviio',
			onPause : function() {
				return (object.live ? this.close() : this.pause());
			},
			onResume : function() {
				return (object.live ? this.play() : this.resume());
			},
			onStart : function(clip) {
			},
			onLastSecond : function(clip) {
				playNextInPlaylist();
			}

		};

		initFlowPlayer("flowplayer_vid", videoPlugins, clip);

		$('.closer').unbind('click');
		$('.closer').click(function() {
			closeMediaPlayerWindow();
		});

		flowplayer().play();
	}
}

function closeMediaPlayerWindow() {
	flowplayer().stop();
	flowplayer().close();
	flowplayer().unload();
	playerIsFullScreen = false;
	$('.lighboxMediaFrame').remove();
	$('.lightbox').remove();
	$('.playlistItem').removeClass('highlighted');
}

function removeSlimScroll(selector) {

	var container = $(selector);
	var scrollerDiv = container.parent();

	if (scrollerDiv && scrollerDiv.hasClass('slimScrollDiv')) {
		$(selector + ' ~ div').remove();
		var w = container.width();
		container.unwrap();
		container.width(w);
	}
}

function resizeElements() {
	var wh = $(window).height();
	var ww = $(window).width();

	$('#wrapper').css('height', wh);
	$('#mainContainer').css('height', wh - 160);
	$('.background').css('height', wh);

	$('#folderNav').css('height', wh - 229);
	$('#folderScrollBox').css('height', $('#folderNav').height() - (2 * 27));

	removeSlimScroll('#folderScrollBox');
	$('#folderScrollBox').slimScroll({
		height : $('#folderScrollBox').height(),
		alwaysVisible : false,
		railVisible : false
	});

	removeSlimScroll('#thumbsGrid');
	$('#thumbsGrid').slimScroll({
		height : $('#folderNav').height()
	});

	var thumbsGridViewPortOffset = 70 - folderGridSpace;
	if ($('#folderNav').is(':visible')) {
		thumbsGridViewPortOffset = thumbsGridViewPortOffset
				+ $('#folderNav').width() + folderGridSpace;
	}

	$('#thumbsGridViewPort').css('height', wh - 229);
	$('#thumbsGridViewPort').css('width', ww - thumbsGridViewPortOffset);
	$('#thumbsGrid').css('height', wh - 229);
	$('#thumbsGrid').css('width', ww - thumbsGridViewPortOffset);

	$('#noContentMessage').css('top', $('#thumbsGridViewPort').height() / 2);
	$('#noContentMessage').css(
			'left',
			$('#thumbsGridViewPort').width() / 2
					- ($('#noContentMessage').width() / 2));

	$('#welcomeMessage').css('top', $('#thumbsGridViewPort').height() / 2);
	$('#welcomeMessage').css(
			'left',
			$('#thumbsGridViewPort').width() / 2
					- ($('#welcomeMessage').width() / 2));

	$('#bottomNav').css('width', $('#mainContainer').width());
	$('#bottomNav').css('top', $('#mainContainer').height() + 58);

	$('#bgImg').css('width', ww);
	$('#bgImg').css('height', wh);
	$('#bgImgTop').css('width', ww);
	$('#bgImgTop').css('height', wh);

	$('#playlistDiv').css('height', wh);
	$('#playlistDiv').css('top', 0);
	$('#playlistScrollBox').css(
			'height',
			$('#playlistDiv').height()
					- (($('#playlistScrollerTop').height() * 5) + 6));

	$('#playlistScrollBox').css('top', $('#playlistScrollerTop').height() + 17);

	$('#playlistUl').css('height', $('#playlistScrollBox').height());

	$('#playlistScrollBoxTransparency').css('height',
			$('#playlistScrollBox').height() + 39);

	$("#playlistHelpText").css('top', (wh / 2) - 100);

	removeSlimScroll('#playlistUl');
	$('#playlistUl').slimScroll({
		height : $('#playlistScrollBox').height()
	});

	navWidth = $('#folderNav').width();

	centerElement('.brandedLoginBox', 'body', -80, 0);
	centerElement('.loginRibbon', 'body', 0, 0);
}

function centerElement(matcher, parentMatcher, topOffset, leftOffset) {
	var top = ($(parentMatcher).height() - $(matcher).height()) / 2 + topOffset;
	if (top < 0) {
		top = 0;
	}

	var left = ($(parentMatcher).width() - $(matcher).width()) / 2 + leftOffset;
	if (left < 0) {
		left = 0;
	}

	$(matcher).css('top', top + 'px');
	$(matcher).css('left', left + 'px');
}

function showMessage(message) {
	if (!message) {
		return;
	}
	$('#messageBox').css('opacity', 0);
	$('#messageBox').show();
	centerElement('#messageBox', 'body', 0, 0);
	$('#userMessage').html(message);
	resizeElements();
	$('#messageBox').animate({
		opacity : 1
	}, 300, "swing");
}

function hideMessage() {

	$('#messageBox').animate({
		opacity : 0
	}, 300, "swing", function() {
		$('#messageBox').hide();
		$('#userMessage').html('');
	});
}

function hideLoginBox(callbackFn) {

	$('#loginWrapper').animate({
		opacity : 0
	}, 500, "swing", function() {
		$('#loginWrapper').hide();
		if (callbackFn) {
			callbackFn();
		}
	});
}

function showMainWindow(callbackFn) {
	$('#wrapper').css('opacity', 0);
	$('#wrapper').show();
	$('#wrapper').animate({
		opacity : 1
	}, 500, "swing", function() {
		if (callbackFn) {
			callbackFn();
		}
	});
}

function setFocusToLoginFields() {
	$('#loginWrapper input').focus();
}

function showLoginBox(callbackFn) {
	$('#loginWrapper').css('opacity', 0);
	$('#loginWrapper').show();
	setFocusToLoginFields();
	resizeElements();
	$('#loginWrapper').animate({
		opacity : 1
	}, 500, "swing", function() {

		if (callbackFn) {
			callbackFn();
		}
	});
}

function hideMainWindow(callbackFn) {

	$('#wrapper').animate({
		opacity : 0
	}, 500, "swing", function() {
		$('#wrapper').hide();
		if (callbackFn) {
			callbackFn();
		}
	});
}

var sec_token = '0';

function doLogout() {
	var actionUrl = logoutUrl + "?authToken=" + sec_token;

	$.ajax({
		url : actionUrl,
		dataType : 'json',
		async : true,
		type : 'POST',
		success : function(data) {
			isResponseOK(data);
			hideMainWindow(showLoginBox);
		},
		error : function() {
			showMessage(messageMap["defaulterror"]);

		}
	});
}

function doLogin() {
	var date = getServiioDate();
	$.ajax({
		url : loginUrl,
		dataType : 'json',
		async : true,
		type : 'POST',
		headers : {
			'X-Serviio-Date' : date,
			'Authorization' : 'Serviio ' + getServiioToken(date)
		},
		success : function(data) {
			if (!isResponseOK(data)) {
				return;
			} else if (data.parameter) {
				sec_token = data.parameter;
				hideLoginBox(function() {
					refreshFolderList(sanitizeId(baseFolderId));
					hideGrid();
					showMainWindow(function() {
						resizeElements();
						loadPlaylist();
					});
				});
			} else {
				showMessage(messageMap["nologin"]);
			}
		},
		error : function() {
			showMessage(messageMap["nologin"]);
		}
	});

}

function getServiioDate() {
	return dateFormat(new Date(), "ddd, dd mmm yyyy  HH:MM:ss Z");
}

function getServiioToken(date) {
	var password = $('#password').val();

	var hmacBytes = Crypto.HMAC(Crypto.SHA1, date, password, {
		asBytes : true
	});
	var encodedKey = Crypto.util.bytesToBase64(hmacBytes);
	return encodedKey;
}

function formatSecondsAsTime(secs, format) {
	var hr = Math.floor(secs / 3600);
	var min = Math.floor((secs - (hr * 3600)) / 60);
	var sec = Math.floor(secs - (hr * 3600) - (min * 60));

	if (hr < 10) {
		hr = "0" + hr;
	}
	if (min < 10) {
		min = "0" + min;
	}
	if (sec < 10) {
		sec = "0" + sec;
	}
	if (!hr) {
		hr = "00";
	}

	if (format != null) {
		var formatted_time = format.replace('hh', hr);
		formatted_time = formatted_time.replace('h', hr * 1 + ""); // check for
		// single
		// hour
		// formatting
		formatted_time = formatted_time.replace('mm', min);
		formatted_time = formatted_time.replace('m', min * 1 + ""); // check for
		// single
		// minute
		// formatting
		formatted_time = formatted_time.replace('ss', sec);
		formatted_time = formatted_time.replace('s', sec * 1 + ""); // check for
		// single
		// second
		// formatting
		return formatted_time;
	} else {
		return hr + ':' + min + ':' + sec;
	}
}

function ScaleImage(srcwidth, srcheight, targetwidth, targetheight, fLetterBox) {

	var result = {
		width : 0,
		height : 0,
		fScaleToTargetWidth : true
	};

	if ((srcwidth <= 0) || (srcheight <= 0) || (targetwidth <= 0)
			|| (targetheight <= 0)) {
		return result;
	}

	// scale to the target width
	var scaleX1 = targetwidth;
	var scaleY1 = (srcheight * targetwidth) / srcwidth;

	// scale to the target height
	var scaleX2 = (srcwidth * targetheight) / srcheight;
	var scaleY2 = targetheight;

	// now figure out which one we should use
	var fScaleOnWidth = (scaleX2 > targetwidth);
	if (fScaleOnWidth) {
		fScaleOnWidth = fLetterBox;
	} else {
		fScaleOnWidth = !fLetterBox;
	}

	if (fScaleOnWidth) {
		result.width = Math.floor(scaleX1);
		result.height = Math.floor(scaleY1);
		result.fScaleToTargetWidth = true;
	} else {
		result.width = Math.floor(scaleX2);
		result.height = Math.floor(scaleY2);
		result.fScaleToTargetWidth = false;
	}
	result.targetleft = Math.floor((targetwidth - result.width) / 2);
	result.targettop = Math.floor((targetheight - result.height) / 2);

	return result;
}

function OnImageLoad(evt) {

	var img = evt.currentTarget;

	// what's the size of this image and it's parent
	var w = img.width;
	var h = img.height;
	var tw = $(img).parent().width();
	if (tw == 0) {
		tw = $(img).parent().parent().width();
	}

	var th = $(img).parent().height();
	if (th == 0) {
		th = $(img).parent().parent().height();
	}

	// compute the new size and offsets
	var result = ScaleImage(w, h, tw, th, true);

	// adjust the image coordinates and size
	img.width = result.width;
	img.height = result.height;
	$(img).css("left", result.targetleft);
	$(img).css("top", result.targettop);
}

function thumbImageSizer(img) {

	// what's the size of this image and it's parent
	var w = img.width;
	var h = img.height;
	var tw = $(img).parent().width();
	var th = $(img).parent().height();

	// compute the new size and offsets
	var result = ScaleImage(w, h, tw, th, true);

	// adjust the image coordinates and size
	img.width = result.width;
	img.height = result.height;
	$(img).css("left", result.targetleft);
	$(img).css("top", result.targettop);
}

function hidePlaylist() {

	$('#playlistDiv, #playlistScrollBox').animate({
		right : "-230px"
	}, 200, "swing", function() {
		$('#playlistDiv, #playlistScrollBox').css('display', 'none');
		$('#playlistHiddenClue').css("display", "block");
		$('#playlistHiddenClue').animate({
			opacity : 0.8
		}, 200, "swing", function() {
		});
	});
	persistPlaylist();
}

function showPlaylist() {

	$.each($('#playlistUl').find('img.thumb'), function(index, element) {
		thumbImageSizer(element);
	});

	$('#playlistDiv, #playlistScrollBox').css('display', 'block');
	$('#playlistHiddenClue').animate({
		opacity : 0
	}, 100, "swing", function() {
		$('#playlistHiddenClue').css("display", "none");
		$('#playlistDiv, #playlistScrollBox').animate({
			"right" : 0
		}, 200, "swing");
	});
}

function persistPlaylist() {

	initPlaylistOrder();
	var playlistString = "";

	$.each(playListOrder, function(index, id) {
		playlistString += id + ":";
	});

	playlistString = playlistString.slice(0, (playlistString.length - 1));

	$.cookie(PLAYLIST_COOKIE_NAME, playlistString, {
		expires : 9999
	});
}

function loadPlaylist() {
	var playlistString = $.cookie(PLAYLIST_COOKIE_NAME)

	if (playlistString != null) {
		$.each(playlistString.split(":"), function(index, id) {
			var actionUrl = itemMetadataUrl.replace('{objectId}', id).replace(
					'{token}', sec_token);
	
			$.ajax({
				url : actionUrl,
				dataType : 'json',
				async : false,
				error : function(error) {
					return;
				},
				success : function(data) {
					if (!isResponseOK(data)) {
						return;
					}
	
					var mediaObject = data.objects[0];
					if (mediaObject != null) {
						addObjectToPlaylist(mediaObject, $("#playlistUl"));
					}
				}
			});
		});
	}
	$("#playlistHiddenClue").css("display", "block");

}

function addObjectToPlaylist(mediaObj, playlistContainerElement) {

	var objId = mediaObj.id;
	playListObjects[objId] = mediaObj;

	var liId = sanitizeId(objId) + playlistIdSuffix
			+ new Date().getMilliseconds();

	var playlistElement = "<li id='" + liId + "' class='playlistItem' >";

	playlistElement += "<div class='playlistImageWrapper'>";
	playlistElement += "<img style='position:absolute' class='thumb' src='"
			+ getThumbnailUrl(mediaObj) + "'  />";
	playlistElement += "</div>";

	if (mediaObj.fileType != "IMAGE") {
		var duration = formatSecondsAsTime(parseInt(mediaObj.duration),
				'hh:mm:ss');
		playlistElement += "<div class='itemTitle'>"
				+ wrapWithTooltipPlaylist(mediaObj.title) +  "</div><div class='itemDuration'>" + duration +"</div>";
	} else {
		playlistElement += "<div class='itemTitle'>"
				+ wrapWithTooltipPlaylist(mediaObj.title) + "</div>";
	}

	playlistElement += "<div class='item-overlay-playlist' id='"
			+ liId
			+ "-overlay' style='cursor:pointer; display:none; margin-left:10px; margin-top:0px;  width:30px; height:40px; "
			+ "z-index:2000; position:absolute;"
			+ " right:10px'><div id='"
			+ liId
			+ "-remove-button' onclick=\"$('#"
			+ liId
			+ "').remove();\" ><img src='images/close_button.png'  /></div></div>";

	playlistElement += "<div class='item-overlay-playlist' id='"
			+ liId
			+ "-play-overlay' style='cursor:pointer; display:none; margin-left:10px; margin-top:0px;  width:30px; height:40px; "
			+ "z-index:2000; position:absolute;"
			+ "right:192px'><div id='"
			+ liId
			+ "-play-button' onclick=\"folderPlayback=false; playPlaylist('"
			+ objId
			+ "');"
			+ "\" ><img src='images/play_icon_small.png' width='30px' height='30px'/></div></div>";

	playlistElement += "</div></li>";

	playListIdsToObjectIdsMap[liId] = objId;

	$(playlistContainerElement).append(playlistElement);

	$('#' + liId).dblclick(function() {
		folderPlayback = false;
		playPlaylist(objId);
	});

	$('#' + liId).mouseover(function() {
		var offset = $('#' + liId).offset().top - 30;

		$("#" + liId + "-overlay").css('top', offset - 7);
		$("#" + liId + "-overlay").css('display', 'block');

		$("#" + liId + "-play-overlay").css('top', offset);
		$("#" + liId + "-play-overlay").css('display', 'block');
	});

	$('#' + liId).mouseout(function(event) {
		$("#" + liId + "-overlay").css('display', 'none');
		$("#" + liId + "-play-overlay").css('display', 'none');
	});

	$('.playlistTooltip').qtip({
		content : {
			attr : 'data-tooltip'
		},
		style : {
			classes : 'ui-tooltip-dark ui-tooltip-rounded ui-tooltip-tipsy'
		},
		position : {
			my : 'top right',
			at : 'center'
		}
	});

}
