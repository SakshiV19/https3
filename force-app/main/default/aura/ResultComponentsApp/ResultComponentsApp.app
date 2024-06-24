<aura:application access="GLOBAL" extends="ltng:outApp">
    <aura:dependency resource="c:dynamicResultViewer" />
    <aura:dependency resource="c:resultViewerPublishMessage" />
    <aura:dependency resource="c:dynamicUISectionContainer" />
    <aura:dependency resource="markup://force:close" type="EVENT" />
    <aura:dependency resource="markup://force:navigatetorecord" type="EVENT" />
</aura:application>