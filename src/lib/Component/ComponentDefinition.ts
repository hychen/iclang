/** Module ComponentDefinition
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
export interface ComponentDefinition {
    /* A display name for the component.
     * - Sentence-case (like a normal sentence)
     * - No ending punctuation.
     */
    friendlyName: string;
    /* Clear, 1 sentence description in the imperative mood.
     */
    description?: string;
    /* Provides supplemental info on top of description.
     */
    extendedDescription?: string;
    /**
     * This optional URL points to somewhere where additional information
     * about the underlying functionality in this component can be found.
     *
     * Be sure and use a fully qualified URL like http://foo.com/bar/baz.
     */
    moreInfoUrl?: string;
    // Can this component be cached?
    cacheable?: boolean;
    // Sync?
    sync?: boolean;
}
