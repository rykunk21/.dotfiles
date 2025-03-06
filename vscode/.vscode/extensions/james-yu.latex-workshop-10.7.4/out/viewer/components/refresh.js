import * as utils from './utils.js';
import { getTrimValue, setTrimValue } from './trimming.js';
import { sendLog } from './connection.js';
import { viewerState, viewerStatePromise } from './state.js';
import { RenderingStates } from './interface.js';
let autoRefreshEnabled = true;
export function IsAutoRefreshEnabled() {
    return autoRefreshEnabled;
}
export function toggleAutoRefresh() {
    autoRefreshEnabled = !autoRefreshEnabled;
    return autoRefreshEnabled;
}
let prevState;
// https://github.com/James-Yu/LaTeX-Workshop/pull/4295#issuecomment-2191226562
export function doneRefresh() {
    refreshing = false;
    clearTimeout(doneRefreshTimeout);
    if (shouldRefreshAgain) {
        shouldRefreshAgain = false;
        void refresh();
    }
}
let refreshing = false;
let shouldRefreshAgain = false;
let doneRefreshTimeout = 0;
export async function refresh() {
    if (!IsAutoRefreshEnabled()) {
        sendLog('Auto reload temporarily disabled.');
        return;
    }
    if (refreshing) {
        shouldRefreshAgain = true;
        sendLog('Auto reload rate-limiting.');
        return;
    }
    // https://github.com/James-Yu/LaTeX-Workshop/pull/4295#issuecomment-2191384019
    refreshing = true;
    clearTimeout(doneRefreshTimeout);
    doneRefreshTimeout = setTimeout(() => doneRefresh(), 1000);
    // Fail-safe. For unknown reasons, the pack may have null values #4076
    const currentState = {
        page: PDFViewerApplication.pdfViewer.currentPageNumber ?? prevState?.page,
        trim: getTrimValue(),
        scale: PDFViewerApplication.pdfViewer.currentScaleValue ?? prevState?.scale,
        scrollMode: PDFViewerApplication.pdfViewer.scrollMode ?? prevState?.scrollMode,
        sidebarView: PDFViewerApplication.pdfSidebar.visibleView ?? prevState?.sidebarView,
        spreadMode: PDFViewerApplication.pdfViewer.spreadMode ?? prevState?.spreadMode,
        scrollTop: document.getElementById('viewerContainer').scrollTop ?? prevState?.scrollTop,
        scrollLeft: document.getElementById('viewerContainer').scrollLeft ?? prevState?.scrollLeft
    };
    prevState = currentState;
    // Note: without showPreviousViewOnLoad = false restoring the position after the refresh will fail if
    // the user has clicked on any link in the past (pdf.js will automatically navigate to that link).
    PDFViewerApplicationOptions.set('showPreviousViewOnLoad', false);
    // Override the spread mode specified in PDF documents with the current one.
    // https://github.com/James-Yu/LaTeX-Workshop/issues/1871
    if (typeof prevState.spreadMode === 'number') {
        PDFViewerApplicationOptions.set('spreadModeOnLoad', prevState.spreadMode);
    }
    const masks = addMasks();
    const cb = () => {
        if (!allPagesRendered()) {
            return;
        }
        removeMasks(masks);
        PDFViewerApplication.eventBus.off('pagerendered', cb);
    };
    PDFViewerApplication.eventBus.on('pagerendered', cb);
    const { encodedPath, docTitle } = utils.parseURL();
    /* eslint-disable */
    const doc = await pdfjsLib.getDocument({
        url: `${utils.pdfFilePrefix}${encodedPath}`,
        cMapUrl: '../cmaps/'
    }).promise;
    PDFViewerApplication.load(doc);
    /* eslint-enable */
    // reset the document title to the original value to avoid duplication
    document.title = docTitle;
}
export async function restoreState() {
    if (prevState === undefined) {
        await restoreDefault();
        return;
    }
    if (prevState.page !== undefined) {
        PDFViewerApplication.pdfViewer.currentPageNumber = prevState.page;
    }
    if (prevState.trim !== undefined) {
        setTrimValue(prevState.trim);
    }
    if (prevState.scale !== undefined) {
        PDFViewerApplication.pdfViewer.currentScaleValue = prevState.scale;
    }
    if (prevState.sidebarView) {
        PDFViewerApplication.pdfSidebar.switchView(prevState.sidebarView);
    }
    if (typeof prevState.scrollMode === 'number' && PDFViewerApplication.pdfViewer.scrollMode !== prevState.scrollMode) {
        PDFViewerApplication.pdfViewer.scrollMode = prevState.scrollMode;
    }
    if (typeof prevState.spreadMode === 'number' && PDFViewerApplication.pdfViewer.spreadMode !== prevState.spreadMode) {
        PDFViewerApplication.pdfViewer.spreadMode = prevState.spreadMode;
    }
    const viewerContainer = document.getElementById('viewerContainer');
    if (typeof prevState.scrollTop === 'number' && viewerContainer.scrollTop !== prevState.scrollTop) {
        viewerContainer.scrollTop = prevState.scrollTop;
    }
    if (typeof prevState.scrollLeft === 'number' && viewerContainer.scrollLeft !== prevState.scrollLeft) {
        viewerContainer.scrollLeft = prevState.scrollLeft;
    }
}
async function restoreDefault() {
    const params = await utils.getParams();
    if (params.trim !== undefined) {
        setTrimValue(params.trim);
    }
    // By setting the scale, scaling will be invoked if necessary.
    // The scale can be a non-number one.
    if (params.scale !== undefined) {
        PDFViewerApplication.pdfViewer.currentScaleValue = params.scale;
    }
    if (params.scrollMode !== undefined) {
        PDFViewerApplication.pdfViewer.scrollMode = params.scrollMode;
    }
    if (params.spreadMode !== undefined) {
        PDFViewerApplication.pdfViewer.spreadMode = params.spreadMode;
    }
    if (!utils.isEmbedded()) {
        return;
    }
    await viewerStatePromise;
    const viewerContainer = document.getElementById('viewerContainer');
    if (typeof viewerState.scrollTop === 'number' && viewerContainer.scrollTop !== viewerState.scrollTop) {
        viewerContainer.scrollTop = viewerState.scrollTop;
    }
    if (typeof viewerState.scrollLeft === 'number' && viewerContainer.scrollLeft !== viewerState.scrollLeft) {
        viewerContainer.scrollLeft = viewerState.scrollLeft;
    }
}
function addMasks() {
    const viewerDom = document.getElementById('viewer');
    const viewerContainer = document.getElementById('viewerContainer');
    const masks = [];
    if (!viewerContainer || !viewerDom) {
        return masks;
    }
    const visiblePages = PDFViewerApplication.pdfViewer._getVisiblePages();
    for (const visiblePage of visiblePages.views) {
        const canvas = visiblePage.view.canvas;
        if (!canvas) {
            continue;
        }
        const viewerBound = viewerDom.getBoundingClientRect();
        const pageBound = visiblePage.view.div.getBoundingClientRect();
        const canvasBound = canvas.getBoundingClientRect();
        const div = document.createElement('div');
        div.className = 'page-loading-mask';
        masks.push(div);
        div.style.display = 'none';
        div.style.left = pageBound.x - viewerBound.x + 'px';
        div.style.top = pageBound.y - viewerBound.y + 'px';
        div.style.width = pageBound.width + 'px';
        div.style.height = pageBound.height + 'px';
        const img = new Image();
        img.src = canvas.toDataURL() ?? '';
        img.style.left = canvasBound.x - pageBound.x + 'px';
        img.style.top = canvasBound.y - pageBound.y + 'px';
        img.style.width = canvasBound.width + 'px';
        img.style.height = canvasBound.height + 'px';
        div.appendChild(img);
        viewerContainer.appendChild(div);
        div.style.display = 'inherit';
    }
    return masks;
}
function allPagesRendered() {
    return PDFViewerApplication.pdfViewer._getVisiblePages().views.every(view => view.view.renderingState === RenderingStates.FINISHED);
}
function removeMasks(masks) {
    for (const mask of masks) {
        mask.classList.add('remove');
    }
    setTimeout(() => {
        for (const mask of masks) {
            mask.remove();
        }
    }, 250);
}
//# sourceMappingURL=refresh.js.map