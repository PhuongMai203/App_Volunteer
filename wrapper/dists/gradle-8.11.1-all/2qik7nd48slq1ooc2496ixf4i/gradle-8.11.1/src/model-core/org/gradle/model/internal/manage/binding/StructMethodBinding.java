/*
 * Copyright 2016 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.gradle.model.internal.manage.binding;

import org.gradle.internal.reflect.PropertyAccessorType;
import org.gradle.model.internal.method.WeaklyTypeReferencingMethod;

import javax.annotation.Nullable;

/**
 * Binds a method declared in a user to its actual implementation.
 */
public interface StructMethodBinding {
    WeaklyTypeReferencingMethod<?, ?> getViewMethod();

    /**
     * Returns the property accessor type of this method, or {@code null} if the method is not a property accessor.
     */
    @Nullable
    PropertyAccessorType getAccessorType();
}
